import 'package:equatable/equatable.dart';

import '../../domain/entities/chat_message.dart';

/// State of the AI Health Assistant conversation.
class HealthAssistantState extends Equatable {
  const HealthAssistantState({
    this.messages = const [],
    this.isResponding = false,
    this.errorMessage,
    this.failedMessageId,
  });

  /// All messages in the conversation, in order.
  final List<ChatMessage> messages;

  /// True while the assistant is producing a response.
  final bool isResponding;

  /// Error message for the last failed send; null when no error.
  final String? errorMessage;

  /// Id of the user message that failed, so it can be retried.
  final String? failedMessageId;

  bool get hasError => errorMessage != null;

  /// True when the latest assistant guidance recommends emergency SOS.
  bool get sosRecommended =>
      messages.any((m) => m.sender == ChatSender.assistant && m.sosRecommended);

  HealthAssistantState copyWith({
    List<ChatMessage>? messages,
    bool? isResponding,
    String? errorMessage,
    String? failedMessageId,
    bool clearError = false,
  }) {
    return HealthAssistantState(
      messages: messages ?? this.messages,
      isResponding: isResponding ?? this.isResponding,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      failedMessageId:
          clearError ? null : (failedMessageId ?? this.failedMessageId),
    );
  }

  @override
  List<Object?> get props => [messages, isResponding, errorMessage, failedMessageId];
}
