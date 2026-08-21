import 'package:equatable/equatable.dart';

/// The assistant's reply produced by the local response engine.
class HealthAssistantResponse extends Equatable {
  const HealthAssistantResponse({
    required this.text,
    this.sosRecommended = false,
  });

  final String text;

  /// True when the reply describes a serious emergency and the UI should
  /// offer the "Open Emergency SOS" action.
  final bool sosRecommended;

  @override
  List<Object?> get props => [text, sosRecommended];
}
