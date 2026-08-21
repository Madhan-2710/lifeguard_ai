import '../../domain/entities/health_assistant_response.dart';

/// Data source boundary for the AI Health Assistant.
///
/// Implementations turn a user message into safe health guidance.
abstract class HealthAssistantDataSource {
  Future<HealthAssistantResponse> getResponse(String userMessage);
}
