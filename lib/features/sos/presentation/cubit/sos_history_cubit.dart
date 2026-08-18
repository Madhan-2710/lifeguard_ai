import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/emergency_event.dart';
import '../../domain/repositories/emergency_event_repository.dart';
import 'sos_history_state.dart';

/// Loads the authenticated user's previous SOS events from
/// `users/{uid}/sos_alerts` and exposes them newest-first.
///
/// Reuses [EmergencyEvent] and [EmergencyEventRepository] — no new entity or
/// repository is introduced. Events with malformed or missing optional fields
/// are parsed with safe defaults by the data layer, so a single bad document
/// never fails the whole history read.
class SosHistoryCubit extends Cubit<SosHistoryState> {
  SosHistoryCubit({required EmergencyEventRepository eventRepository})
    : _eventRepo = eventRepository,
      super(const SosHistoryState());

  final EmergencyEventRepository _eventRepo;

  /// Loads the event history.
  ///
  /// Emits [SosHistoryStatus.loading] first, then [SosHistoryStatus.loaded]
  /// (newest-first), [SosHistoryStatus.empty], or [SosHistoryStatus.failure].
  Future<void> loadHistory() async {
    emit(const SosHistoryState(status: SosHistoryStatus.loading));
    try {
      final events = await _eventRepo.getEventHistory();
      final sorted = _sortNewestFirst(events);
      if (sorted.isEmpty) {
        emit(const SosHistoryState(status: SosHistoryStatus.empty));
      } else {
        emit(
          SosHistoryState(status: SosHistoryStatus.loaded, events: sorted),
        );
      }
    } catch (_) {
      emit(
        SosHistoryState(
          status: SosHistoryStatus.failure,
          message: AppStrings.sosHistoryLoadError,
        ),
      );
    }
  }

  /// Sorts events by [EmergencyEvent.timestamp] descending (newest first).
  /// Events without a timestamp sort last so they never crash the ordering.
  static List<EmergencyEvent> _sortNewestFirst(List<EmergencyEvent> events) {
    final sorted = [...events];
    sorted.sort((a, b) {
      final at = a.timestamp;
      final bt = b.timestamp;
      if (at == null && bt == null) return 0;
      if (at == null) return 1;
      if (bt == null) return -1;
      return bt.compareTo(at);
    });
    return sorted;
  }
}
