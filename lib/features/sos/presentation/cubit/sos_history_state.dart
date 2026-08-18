import 'package:equatable/equatable.dart';

import '../../domain/entities/emergency_event.dart';

/// High-level status of the SOS history screen.
enum SosHistoryStatus {
  /// No load has been attempted yet.
  initial,

  /// History read is in flight.
  loading,

  /// History loaded and contains at least one event.
  loaded,

  /// History loaded but contains no events.
  empty,

  /// The Firestore read failed.
  failure,
}

/// State for the SOS history screen.
class SosHistoryState extends Equatable {
  const SosHistoryState({
    this.status = SosHistoryStatus.initial,
    this.events = const [],
    this.message,
  });

  final SosHistoryStatus status;

  /// Events sorted newest-first (null timestamps last).
  final List<EmergencyEvent> events;

  /// Human-readable error message when [status] is [SosHistoryStatus.failure].
  final String? message;

  SosHistoryState copyWith({
    SosHistoryStatus? status,
    List<EmergencyEvent>? events,
    String? message,
    bool clearMessage = false,
  }) {
    return SosHistoryState(
      status: status ?? this.status,
      events: events ?? this.events,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, events, message];
}
