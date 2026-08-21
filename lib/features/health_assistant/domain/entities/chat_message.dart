import 'package:equatable/equatable.dart';

/// Who produced a chat message in the AI Health Assistant conversation.
enum ChatSender { user, assistant }

/// A single message in the AI Health Assistant conversation.
class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.sosRecommended = false,
    this.isError = false,
  });

  final String id;
  final String text;
  final ChatSender sender;
  final DateTime timestamp;

  /// True when the assistant response recommends opening the emergency SOS.
  final bool sosRecommended;

  /// True when this user message failed to receive a response.
  final bool isError;

  ChatMessage copyWith({
    String? id,
    String? text,
    ChatSender? sender,
    DateTime? timestamp,
    bool? sosRecommended,
    bool? isError,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      sosRecommended: sosRecommended ?? this.sosRecommended,
      isError: isError ?? this.isError,
    );
  }

  @override
  List<Object?> get props => [id, text, sender, timestamp, sosRecommended, isError];
}
