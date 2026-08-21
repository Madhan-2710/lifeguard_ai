import '../entities/health_assistant_response.dart';

/// Repository boundary for the AI Health Assistant.
///
/// Implementations produce safe, non-diagnostic health guidance for a
/// user message. No diagnosis, no medication prescription, and serious
/// symptoms always recommend emergency/professional assistance.
abstract class HealthAssistantRepository {
  Future<HealthAssistantResponse> getResponse(String userMessage);
}
