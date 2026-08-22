import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/health_context.dart';
import '../../domain/repositories/health_assistant_repository.dart';
import '../../domain/services/health_context_builder.dart';
import 'health_assistant_state.dart';

/// Orchestrates the AI Health Assistant conversation.
///
/// - starts with a welcome message
/// - [sendMessage] appends the user message and the assistant response
/// - loads/reuses the user's safe health context (medical profile) and passes
///   it into the response path; if the context cannot be loaded the assistant
///   still responds using its existing behavior
/// - prevents empty and concurrent sends
/// - [retryLastMessage] re-sends the last failed user message
/// - [clearConversation] resets to just the welcome message
class HealthAssistantCubit extends Cubit<HealthAssistantState> {
  HealthAssistantCubit({
    required this._repository,
    this._contextBuilder,
  }) : super(HealthAssistantState(messages: [_welcomeMessage()]));

  final HealthAssistantRepository _repository;
  final HealthContextBuilder? _contextBuilder;

  HealthContext? _cachedContext;
  bool _contextLoadAttempted = false;
  bool _sendInFlight = false;
  int _messageCounter = 0;

  static ChatMessage _welcomeMessage() => ChatMessage(
        id: 'welcome',
        text: AppStrings.healthAssistantWelcome,
        sender: ChatSender.assistant,
        timestamp: DateTime.now(),
      );

  String _nextId() => 'msg-${_messageCounter++}';

  /// Sends a user message and appends the assistant's response.
  ///
  /// No-op for empty/whitespace text and while a send is already in flight.
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _sendInFlight || state.isResponding) return;

    _sendInFlight = true;
    final userMessage = ChatMessage(
      id: _nextId(),
      text: trimmed,
      sender: ChatSender.user,
      timestamp: DateTime.now(),
    );
    emit(state.copyWith(
      messages: [...state.messages, userMessage],
      isResponding: true,
      clearError: true,
    ));

    try {
      final context = await _loadContext();
      final response = await _repository.getResponse(trimmed, context: context);
      if (isClosed) return;
      emit(state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            id: _nextId(),
            text: response.text,
            sender: ChatSender.assistant,
            timestamp: DateTime.now(),
            sosRecommended: response.sosRecommended,
          ),
        ],
        isResponding: false,
        isUsingProfileContext: context != null && !context.isEmpty,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        messages: state.messages
            .map((m) => m.id == userMessage.id ? m.copyWith(isError: true) : m)
            .toList(),
        isResponding: false,
        errorMessage: AppStrings.healthAssistantError,
        failedMessageId: userMessage.id,
      ));
    } finally {
      _sendInFlight = false;
    }
  }

  /// Loads (once) and reuses the user's safe health context.
  ///
  /// Any failure is contained: the assistant keeps working without profile
  /// context.
  Future<HealthContext?> _loadContext() async {
    if (_contextLoadAttempted) return _cachedContext;
    _contextLoadAttempted = true;
    final builder = _contextBuilder;
    if (builder == null) return null;
    try {
      _cachedContext = await builder.build();
    } catch (_) {
      _cachedContext = null;
    }
    return _cachedContext;
  }

  /// Re-sends the last failed user message.
  Future<void> retryLastMessage() async {
    final failedId = state.failedMessageId;
    if (failedId == null || _sendInFlight || state.isResponding) return;

    final failed = state.messages.where((m) => m.id == failedId).toList();
    if (failed.isEmpty) return;

    emit(state.copyWith(
      messages: state.messages.where((m) => m.id != failedId).toList(),
      clearError: true,
    ));
    await sendMessage(failed.first.text);
  }

  /// Clears the conversation back to just the welcome message.
  void clearConversation() {
    _sendInFlight = false;
    emit(HealthAssistantState(
      messages: [_welcomeMessage()],
      isUsingProfileContext: _cachedContext != null && !_cachedContext!.isEmpty,
    ));
  }
}
