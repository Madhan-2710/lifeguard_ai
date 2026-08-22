import '../../domain/entities/health_assistant_response.dart';
import '../../domain/entities/health_context.dart';

/// Data source boundary for the AI Health Assistant.
///
/// Implementations turn a user message into safe health guidance. An
/// optional [HealthContext] (built from the user's saved medical profile)
/// may be provided to make medication guidance allergy- and
/// condition-aware; it is never required and never suppresses emergency
/// escalation.
abstract class HealthAssistantDataSource {
  Future<HealthAssistantResponse> getResponse(
    String userMessage, {
    HealthContext? context,
  });
}
