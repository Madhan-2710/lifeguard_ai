import '../entities/health_assistant_response.dart';
import '../entities/health_context.dart';

/// Repository boundary for the AI Health Assistant.
///
/// Implementations produce safe, non-diagnostic health guidance for a
/// user message. No diagnosis, no medication prescription, and serious
/// symptoms always recommend emergency/professional assistance.
///
/// An optional [HealthContext] (built from the authenticated user's saved
/// medical profile) may be passed in so medication guidance can be
/// allergy- and condition-aware. It is never required and never suppresses
/// emergency escalation.
abstract class HealthAssistantRepository {
  Future<HealthAssistantResponse> getResponse(
    String userMessage, {
    HealthContext? context,
  });
}
