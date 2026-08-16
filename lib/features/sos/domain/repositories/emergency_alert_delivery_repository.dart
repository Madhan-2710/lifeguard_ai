import '../entities/emergency_alert_delivery.dart';

/// Application-facing abstraction for trusted emergency alert delivery.
abstract class EmergencyAlertDeliveryRepository {
  /// Requests backend delivery for one persisted event.
  ///
  /// The backend owns authentication, contact loading, Twilio calls, and
  /// idempotency. The Flutter client never handles provider credentials.
  Future<EmergencyAlertDeliveryResult> deliverEmergencyAlert({
    required String eventId,
  });
}
