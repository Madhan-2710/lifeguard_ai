import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/health_assistant_response.dart';
import '../../domain/entities/health_context.dart';
import 'emergency_safety_override.dart';
import 'health_assistant_data_source.dart';
import 'llm_health_assistant_config.dart';
import 'local_health_assistant_data_source.dart';

/// LLM-backed data source for the AI Health Assistant.
///
/// Calls an OpenAI-compatible chat-completions endpoint and maps the reply
/// into [HealthAssistantResponse]. Safety guarantees:
/// - deterministic emergency override for the seven critical categories
/// - a timeout on every request
/// - malformed responses fall back to local mode
/// - any exception (no network, auth failure, ...) falls back to local mode
class LlmHealthAssistantDataSource implements HealthAssistantDataSource {
  LlmHealthAssistantDataSource({
    required this.config,
    http.Client? client,
    LocalHealthAssistantDataSource? localFallback,
    EmergencySafetyOverride? safetyOverride,
  })  : _client = client ?? http.Client(),
        _localFallback =
            localFallback ?? const LocalHealthAssistantDataSource(),
        _safetyOverride = safetyOverride ?? const EmergencySafetyOverride();

  final LlmHealthAssistantConfig config;
  final http.Client _client;
  final LocalHealthAssistantDataSource _localFallback;
  final EmergencySafetyOverride _safetyOverride;

  static const String _systemPrompt =
      'You are LifeGuard AI, a health and first-aid assistant. You are NOT a '
      'doctor and must never provide a definite diagnosis, prescribe '
      'prescription-only medication, or claim the user is medically safe. '
      'You may answer broad health questions, not only first-aid questions. '
      'When the user explicitly asks what medicine may help, you MAY suggest '
      'common non-prescription (OTC) medicines or medication categories '
      'generally used for the reported symptom, when appropriate. Structure '
      'medication guidance clearly with these sections: 1) What you can do '
      'now, 2) Possible OTC medicine options, 3) Important precautions, '
      '4) When to see a doctor, 5) Emergency warning signs. Before '
      'suggesting medication, consider available information such as age, '
      'symptoms and duration, severity, allergies, existing medicines, '
      'chronic conditions, and pregnancy when relevant and voluntarily '
      'provided. If important safety information is missing, ask a short '
      'relevant follow-up question or recommend confirming with a doctor or '
      'pharmacist. Do NOT provide a definite diagnosis from symptoms alone, '
      'prescribe prescription-only medicines, recommend antibiotics without '
      'clinician evaluation, invent a prescription, change an existing '
      'prescription, tell users to stop prescribed medication without '
      'professional advice, or guarantee that a medicine is safe for a '
      'particular person. Doctor/pharmacist consultation must remain an '
      'important part of medication guidance, particularly for persistent, '
      'severe, recurrent, unusual, or worsening symptoms. If the situation is '
      'a medical emergency, set "sos_recommended" to true and direct the '
      'user to emergency care — medication suggestions must never delay '
      'emergency care. Respond ONLY with a JSON object in this exact shape: '
      '{"text": "your guidance", "sos_recommended": true|false}.';

  @override
  Future<HealthAssistantResponse> getResponse(
    String userMessage, {
    HealthContext? context,
  }) async {
    final category = _safetyOverride.matchCategory(userMessage);
    try {
      final raw = await _client
          .post(
            Uri.parse(config.apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${config.apiKey}',
            },
            body: jsonEncode(_buildRequestBody(userMessage, context)),
          )
          .timeout(config.timeout);

      final parsed = _parseLlmResponse(raw);
      if (parsed == null) {
        return _fallbackResponse(userMessage, category, context);
      }
      return HealthAssistantResponse(
        text: parsed.text,
        // Deterministic safety override: the seven critical categories always
        // recommend SOS even if the model says otherwise.
        sosRecommended: category != null || parsed.sosRecommended,
      );
    } catch (_) {
      // Timeout, no network, auth failure, or any other exception → local.
      return _fallbackResponse(userMessage, category, context);
    }
  }

  /// Builds the chat-completions request body. The medical context is passed
  /// SEPARATELY from the user's message as its own system message, so the
  /// model can use it as safe context without confusing it with the user's
  /// current question.
  Map<String, Object> _buildRequestBody(
    String userMessage,
    HealthContext? context,
  ) {
    final messages = <Map<String, Object>>[
      {'role': 'system', 'content': _systemPrompt},
    ];
    if (context != null && !context.isEmpty) {
      messages.add({
        'role': 'system',
        'content': 'MEDICAL CONTEXT (user-provided/stored information):\n'
            '${context.toPromptSection()}\n\n'
            'This context is user-provided or stored profile data. Do not '
            'invent missing medical history, do not assume the profile is '
            'complete, and never override emergency safety rules.',
      });
    }
    messages.add({'role': 'user', 'content': userMessage});
    return {
      'model': config.model,
      'messages': messages,
      'temperature': 0.3,
      'max_tokens': 500,
    };
  }

  /// Parses an OpenAI-compatible response. Returns null when malformed.
  ({String text, bool sosRecommended})? _parseLlmResponse(http.Response raw) {
    if (raw.statusCode != 200) return null;
    try {
      final decoded = jsonDecode(raw.body);
      if (decoded is! Map<String, dynamic>) return null;
      final choices = decoded['choices'];
      if (choices is! List || choices.isEmpty) return null;
      final first = choices.first;
      if (first is! Map<String, dynamic>) return null;
      final message = first['message'];
      if (message is! Map<String, dynamic>) return null;
      final content = message['content'];
      if (content is! String || content.trim().isEmpty) return null;
      return _parseContent(content.trim());
    } catch (_) {
      return null;
    }
  }

  /// Parses the model's content. The model is asked for JSON but plain text
  /// is tolerated. Returns null only when the content is unusable.
  ({String text, bool sosRecommended})? _parseContent(String content) {
    final cleaned = _stripCodeFences(content);
    try {
      final decoded = jsonDecode(cleaned);
      if (decoded is Map<String, dynamic>) {
        final text = decoded['text'];
        if (text is String && text.trim().isNotEmpty) {
          return (
            text: text.trim(),
            sosRecommended: decoded['sos_recommended'] == true,
          );
        }
      }
    } catch (_) {
      // Not JSON — fall through to plain-text handling.
    }
    if (cleaned.isEmpty) return null;
    return (text: cleaned, sosRecommended: false);
  }

  String _stripCodeFences(String content) {
    final trimmed = content.trim();
    if (!trimmed.startsWith('```')) return trimmed;
    final firstNewline = trimmed.indexOf('\n');
    if (firstNewline == -1) return trimmed;
    var body = trimmed.substring(firstNewline + 1);
    if (body.endsWith('```')) {
      body = body.substring(0, body.length - 3);
    }
    return body.trim();
  }

  /// Local-mode fallback. For the seven critical categories the response is
  /// fully deterministic and always recommends SOS; everything else is
  /// delegated to the offline engine (with the same safe context).
  Future<HealthAssistantResponse> _fallbackResponse(
    String userMessage,
    EmergencyCategory? category,
    HealthContext? context,
  ) async {
    if (category != null) {
      return HealthAssistantResponse(
        text: _safetyOverride.guidanceFor(category),
        sosRecommended: true,
      );
    }
    return _localFallback.getResponse(userMessage, context: context);
  }
}
