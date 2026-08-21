import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/health_assistant_repository.dart';
import 'health_assistant_state.dart';

/// Orchestrates the AI Health Assistant conversation.
///
/// - starts with a welcome message
/// - [sendMessage] appends the user message and the assistant response
/// - prevents empty and concurrent sends
/// - [retryLastMessage] re-sends the last failed user message
/// - [clearConversation] resets to just the welcome message
class HealthAssistantCubit extends Cubit<HealthAssistantState> {
  HealthAssistantCubit({required this._repository})
      : super(HealthAssistantState(messages: [_welcomeMessage()]));

  final HealthAssistantRepository _repository;
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
      final response = await _repository.getResponse(trimmed);
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
    emit(HealthAssistantState(messages: [_welcomeMessage()]));
  }
}
