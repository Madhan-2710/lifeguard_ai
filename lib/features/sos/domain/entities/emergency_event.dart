import 'package:equatable/equatable.dart';

import 'emergency_alert_delivery.dart';

/// Status of an emergency (SOS) event.
///
/// Phase 3A only *prepares* the event. Actual SMS / network delivery to
/// contacts is Phase 3B, so an event is never marked as `sent`.
enum EmergencyEventStatus {
  /// Event created but not yet processed.
  pending,

  /// Location could not be obtained, so the event could not be prepared.
  locationFailed,

  /// Event fully prepared (location + contacts captured) and persisted.
  ready,

  /// User cancelled the SOS before it was prepared.
  cancelled,

  /// Preparation failed for another reason (contacts load, persistence...).
  failed,
}

/// A single emergency (SOS) event owned by the authenticated user.
///
/// Events are stored privately under `users/{userId}/sos_alerts/{eventId}`.
class EmergencyEvent extends Equatable {
  const EmergencyEvent({
    required this.id,
    required this.userId,
    this.latitude,
    this.longitude,
    this.timestamp,
    this.locationLink,
    this.contactIds = const [],
    this.status = EmergencyEventStatus.pending,
    this.message,
    this.deliveryStatus = EmergencyAlertDeliveryStatus.ready,
    this.deliveryStartedAt,
    this.deliveryCompletedAt,
    this.successfulContactIds = const [],
    this.failedContactIds = const [],
    this.deliveryError,
  });

  final String id;
  final String userId;
  final double? latitude;
  final double? longitude;
  final DateTime? timestamp;
  final String? locationLink;
  final List<String> contactIds;
  final EmergencyEventStatus status;
  final String? message;
  final EmergencyAlertDeliveryStatus deliveryStatus;
  final DateTime? deliveryStartedAt;
  final DateTime? deliveryCompletedAt;
  final List<String> successfulContactIds;
  final List<String> failedContactIds;
  final String? deliveryError;

  EmergencyEvent copyWith({
    String? id,
    String? userId,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    String? locationLink,
    List<String>? contactIds,
    EmergencyEventStatus? status,
    String? message,
    EmergencyAlertDeliveryStatus? deliveryStatus,
    DateTime? deliveryStartedAt,
    DateTime? deliveryCompletedAt,
    List<String>? successfulContactIds,
    List<String>? failedContactIds,
    String? deliveryError,
    bool clearMessage = false,
  }) {
    return EmergencyEvent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      locationLink: locationLink ?? this.locationLink,
      contactIds: contactIds ?? this.contactIds,
      status: status ?? this.status,
      message: clearMessage ? null : (message ?? this.message),
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      deliveryStartedAt: deliveryStartedAt ?? this.deliveryStartedAt,
      deliveryCompletedAt: deliveryCompletedAt ?? this.deliveryCompletedAt,
      successfulContactIds: successfulContactIds ?? this.successfulContactIds,
      failedContactIds: failedContactIds ?? this.failedContactIds,
      deliveryError: deliveryError ?? this.deliveryError,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    latitude,
    longitude,
    timestamp,
    locationLink,
    contactIds,
    status,
    message,
    deliveryStatus,
    deliveryStartedAt,
    deliveryCompletedAt,
    successfulContactIds,
    failedContactIds,
    deliveryError,
  ];
}
