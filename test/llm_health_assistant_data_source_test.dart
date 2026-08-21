import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lifeguard_ai/features/health_assistant/data/datasources/llm_health_assistant_config.dart';
import 'package:lifeguard_ai/features/health_assistant/data/datasources/llm_health_assistant_data_source.dart';

void main() {
  const config = LlmHealthAssistantConfig(
    provider: HealthAssistantProvider.llm,
    apiKey: 'test-key',
    apiUrl: 'https://example.com/v1/chat/completions',
    model: 'test-model',
    timeout: Duration(milliseconds: 200),
  );

  LlmHealthAssistantDataSource dataSourceWith(MockClient client) =>
      LlmHealthAssistantDataSource(config: config, client: client);

  http.Response llmResponse(String content, {int status = 200}) => http.Response(
        jsonEncode({
          'choices': [
            {
              'message': {'content': content},
            },
          ],
        }),
        status,
        headers: {'content-type': 'application/json'},
      );

  group('LlmHealthAssistantDataSource', () {
    test('successful LLM response maps into HealthAssistantResponse', () async {
      final client = MockClient((request) async {
        expect(request.url.toString(), config.apiUrl);
        expect(request.headers['Authorization'], 'Bearer test-key');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['model'], 'test-model');
        return llmResponse(jsonEncode({
          'text': 'Clean the cut with water and cover it.',
          'sos_recommended': false,
        }));
      });

      final response = await dataSourceWith(client).getResponse('small cut');
      expect(response.text, 'Clean the cut with water and cover it.');
      expect(response.sosRecommended, isFalse);
    });

    test('system allows OTC suggestions with safety guardrails',
        () async {
      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        final messages = body['messages'] as List<dynamic>;
        final system = messages
            .firstWhere((m) => m['role'] == 'system')['content'] as String;
        // May suggest OTC medicines when the user asks.
        expect(system, contains('non-prescription (OTC)'));
        expect(system, contains('Possible OTC medicine options'));
        // Must not diagnose, prescribe Rx-only meds, or guarantee safety.
        expect(system, contains('definite diagnosis'));
        expect(system, contains('prescription-only'));
        expect(system, contains('antibiotics'));
        expect(system, contains('guarantee that a medicine is safe'));
        // Emergency care must never be delayed by medication suggestions.
        expect(system, contains('sos_recommended'));
        expect(system, contains('never delay emergency care'));
        return llmResponse(jsonEncode({
          'text': 'Guidance.',
          'sos_recommended': false,
        }));
      });

      final response = await dataSourceWith(client).getResponse('headache');
      expect(response.text, 'Guidance.');
    });

    test('LLM SOS recommendation is honored', () async {
      final client = MockClient((request) async {
        return llmResponse(jsonEncode({
          'text': 'Call emergency services now.',
          'sos_recommended': true,
        }));
      });

      final response = await dataSourceWith(client).getResponse('chest pain');
      expect(response.sosRecommended, isTrue);
      expect(response.text, 'Call emergency services now.');
    });

    test('safety override forces SOS even when the LLM says no', () async {
      final client = MockClient((request) async {
        return llmResponse(jsonEncode({
          'text': 'This seems minor, rest for a while.',
          'sos_recommended': false,
        }));
      });

      final response =
          await dataSourceWith(client).getResponse('my friend is having a seizure');
      expect(response.sosRecommended, isTrue);
    });

    test('timeout falls back to local mode', () async {
      final client = MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        return llmResponse('{}');
      });

      final response = await dataSourceWith(client).getResponse('small cut');
      expect(response.text, isNotEmpty);
      expect(response.sosRecommended, isFalse);
    });

    test('exception falls back to local mode', () async {
      final client = MockClient((request) async {
        throw http.ClientException('no network');
      });

      final response = await dataSourceWith(client).getResponse('small cut');
      expect(response.text, isNotEmpty);
      expect(response.sosRecommended, isFalse);
    });

    test('malformed response falls back to local mode', () async {
      final client = MockClient((request) async {
        return http.Response('not json at all', 200);
      });

      final response = await dataSourceWith(client).getResponse('small cut');
      expect(response.text, isNotEmpty);
      expect(response.sosRecommended, isFalse);
    });

    test('non-200 response falls back to local mode', () async {
      final client = MockClient((request) async {
        return http.Response('unauthorized', 401);
      });

      final response = await dataSourceWith(client).getResponse('small cut');
      expect(response.text, isNotEmpty);
      expect(response.sosRecommended, isFalse);
    });

    test('emergency fallback text is deterministic and recommends SOS',
        () async {
      final client = MockClient((request) async {
        throw http.ClientException('no network');
      });

      final response =
          await dataSourceWith(client).getResponse('he is having a seizure');
      expect(response.sosRecommended, isTrue);
      expect(response.text.toLowerCase(), contains('emergency'));
    });
  });

  group('LlmHealthAssistantConfig', () {
    test('defaults to local provider when no credential is available', () {
      final config = LlmHealthAssistantConfig.fromEnvironment();
      expect(config.provider, HealthAssistantProvider.local);
      expect(config.useLlm, isFalse);
    });

    test('useLlm requires both the llm provider and an api key', () {
      const noKey = LlmHealthAssistantConfig(
        provider: HealthAssistantProvider.llm,
      );
      expect(noKey.useLlm, isFalse);

      const withKey = LlmHealthAssistantConfig(
        provider: HealthAssistantProvider.llm,
        apiKey: 'sk-test',
      );
      expect(withKey.useLlm, isTrue);

      const localWithKey = LlmHealthAssistantConfig(
        provider: HealthAssistantProvider.local,
        apiKey: 'sk-test',
      );
      expect(localWithKey.useLlm, isFalse);
    });
  });
}
