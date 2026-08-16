import 'package:equatable/equatable.dart';

/// Delivery lifecycle for alerts generated from an emergency event.
enum EmergencyAlertDeliveryStatus {
  ready,
  sending,
  sent,
  partiallySent,
  failed,
}

/// Safe result returned by the trusted backend after delivery processing.
class EmergencyAlertDeliveryResult extends Equatable {
  const EmergencyAlertDeliveryResult({
    required this.eventId,
    required this.status,
    this.successfulContactIds = const [],
    this.failedContactIds = const [],
    this.error,
    this.alreadyDelivered = false,
    this.deliveryInProgress = false,
  });

  final String eventId;
  final EmergencyAlertDeliveryStatus status;
  final List<String> successfulContactIds;
  final List<String> failedContactIds;
  final String? error;
  final bool alreadyDelivered;
  final bool deliveryInProgress;

  bool get isSuccessful => status == EmergencyAlertDeliveryStatus.sent;

  @override
  List<Object?> get props => [
        eventId,
        status,
        successfulContactIds,
        failedContactIds,
        error,
        alreadyDelivered,
        deliveryInProgress,
      ];
}
