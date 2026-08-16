import 'package:equatable/equatable.dart';
import '../../domain/entities/emergency_event.dart';

/// High-level status of the SOS workflow.
enum SosStatus {
  /// No SOS in progress.
  idle,

  /// 5-second countdown running; user can still cancel.
  countdown,

  /// Countdown finished; capturing GPS location.
  locating,

  /// Location captured; loading emergency contacts.
  loadingContacts,

  /// Contacts loaded; persisting the emergency event.
  preparing,

  /// Emergency event fully prepared and persisted (delivery is Phase 3B).
  ready,

  /// User cancelled the SOS.
  cancelled,

  /// No emergency contacts configured — workflow stopped.
  noContacts,

  /// Preparation failed (location, contacts, or persistence).
  failed,
}

class SosState extends Equatable {
  const SosState({
    this.status = SosStatus.idle,
    this.countdownSeconds = 0,
    this.latitude,
    this.longitude,
    this.timestamp,
    this.locationLink,
    this.contactCount = 0,
    this.event,
    this.message,
    this.permissionDenied = false,
  });

  final SosStatus status;
  final int countdownSeconds;
  final double? latitude;
  final double? longitude;
  final DateTime? timestamp;
  final String? locationLink;
  final int contactCount;
  final EmergencyEvent? event;
  final String? message;

  /// True when the failure was caused by permanently denied permission,
  /// so the UI can offer an "Open Settings" action.
  final bool permissionDenied;

  /// Whether an SOS operation is currently in flight (cannot be re-triggered).
  bool get isActive =>
      status == SosStatus.countdown ||
      status == SosStatus.locating ||
      status == SosStatus.loadingContacts ||
      status == SosStatus.preparing;

  SosState copyWith({
    SosStatus? status,
    int? countdownSeconds,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    String? locationLink,
    int? contactCount,
    EmergencyEvent? event,
    String? message,
    bool? permissionDenied,
    bool clearMessage = false,
  }) {
    return SosState(
      status: status ?? this.status,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      locationLink: locationLink ?? this.locationLink,
      contactCount: contactCount ?? this.contactCount,
      event: event ?? this.event,
      message: clearMessage ? null : (message ?? this.message),
      permissionDenied: permissionDenied ?? this.permissionDenied,
    );
  }

  @override
  List<Object?> get props => [
    status,
    countdownSeconds,
    latitude,
    longitude,
    timestamp,
    locationLink,
    contactCount,
    event,
    message,
    permissionDenied,
  ];
}
