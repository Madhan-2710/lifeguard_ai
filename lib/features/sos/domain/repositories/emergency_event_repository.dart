import '../entities/emergency_event.dart';

/// Repository for emergency (SOS) events.
///
/// Events are private to the authenticated user and stored under
/// `users/{userId}/sos_alerts/{eventId}`.
abstract class EmergencyEventRepository {
  /// Persists a new emergency event and returns it with its assigned id.
  Future<EmergencyEvent> createEvent(EmergencyEvent event);

  /// Updates the status (and optional message) of an existing event.
  Future<EmergencyEvent> updateEventStatus(
    String eventId,
    EmergencyEventStatus status, {
    String? message,
  });

  /// Fetches a single event, or null when it does not exist.
  Future<EmergencyEvent?> getEvent(String eventId);
}
