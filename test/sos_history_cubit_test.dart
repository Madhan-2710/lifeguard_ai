import 'package:flutter_test/flutter_test.dart';
import 'package:lifeguard_ai/features/sos/domain/entities/emergency_alert_delivery.dart';
import 'package:lifeguard_ai/features/sos/domain/entities/emergency_event.dart';
import 'package:lifeguard_ai/features/sos/domain/repositories/emergency_event_repository.dart';
import 'package:lifeguard_ai/features/sos/presentation/cubit/sos_history_cubit.dart';
import 'package:lifeguard_ai/features/sos/presentation/cubit/sos_history_state.dart';

void main() {
  group('SosHistoryCubit', () {
    test('initial state is initial with no events', () {
      final cubit = SosHistoryCubit(eventRepository: _FakeHistoryRepository());
      expect(cubit.state.status, SosHistoryStatus.initial);
      expect(cubit.state.events, isEmpty);
      cubit.close();
    });

    test('loading state is emitted while the history read is in flight', () async {
      final cubit = SosHistoryCubit(
        eventRepository: _FakeHistoryRepository(
          events: [_event('e1', DateTime(2025, 1, 1))],
          delay: const Duration(milliseconds: 50),
        ),
      );

      final states = <SosHistoryStatus>[];
      final sub = cubit.stream.listen((s) => states.add(s.status));

      final future = cubit.loadHistory();
      // The loading state must be emitted synchronously before the read
      // completes.
      expect(cubit.state.status, SosHistoryStatus.loading);
      await future;
      await sub.cancel();

      expect(states, contains(SosHistoryStatus.loading));
      expect(cubit.state.status, SosHistoryStatus.loaded);
      cubit.close();
    });

    test('history loading success exposes events newest-first', () async {
      final cubit = SosHistoryCubit(
        eventRepository: _FakeHistoryRepository(
          events: [
            _event('old', DateTime(2025, 1, 1)),
            _event('new', DateTime(2025, 3, 1)),
            _event('mid', DateTime(2025, 2, 1)),
          ],
        ),
      );

      await cubit.loadHistory();

      expect(cubit.state.status, SosHistoryStatus.loaded);
      expect(cubit.state.events.map((e) => e.id), ['new', 'mid', 'old']);
      cubit.close();
    });

    test('events without a timestamp sort last and never crash ordering',
        () async {
      final cubit = SosHistoryCubit(
        eventRepository: _FakeHistoryRepository(
          events: [
            _event('no-time', null),
            _event('new', DateTime(2025, 3, 1)),
            _event('old', DateTime(2025, 1, 1)),
          ],
        ),
      );

      await cubit.loadHistory();

      expect(cubit.state.status, SosHistoryStatus.loaded);
      expect(cubit.state.events.map((e) => e.id), ['new', 'old', 'no-time']);
      cubit.close();
    });

    test('empty history emits empty state', () async {
      final cubit = SosHistoryCubit(
        eventRepository: _FakeHistoryRepository(events: const []),
      );

      await cubit.loadHistory();

      expect(cubit.state.status, SosHistoryStatus.empty);
      expect(cubit.state.events, isEmpty);
      cubit.close();
    });

    test('Firestore failure emits failure state with a message', () async {
      final cubit = SosHistoryCubit(
        eventRepository: _FakeHistoryRepository(fail: true),
      );

      await cubit.loadHistory();

      expect(cubit.state.status, SosHistoryStatus.failure);
      expect(cubit.state.message, isNotNull);
      expect(cubit.state.events, isEmpty);
      cubit.close();
    });

    test('retry after failure can recover', () async {
      final repo = _FakeHistoryRepository(
        events: [_event('e1', DateTime(2025, 1, 1))],
        fail: true,
      );
      final cubit = SosHistoryCubit(eventRepository: repo);

      await cubit.loadHistory();
      expect(cubit.state.status, SosHistoryStatus.failure);

      repo.fail = false;
      await cubit.loadHistory();
      expect(cubit.state.status, SosHistoryStatus.loaded);
      expect(cubit.state.events, hasLength(1));
      cubit.close();
    });
  });
}

EmergencyEvent _event(String id, DateTime? timestamp) {
  return EmergencyEvent(
    id: id,
    userId: 'user-1',
    timestamp: timestamp,
    status: EmergencyEventStatus.ready,
    deliveryStatus: EmergencyAlertDeliveryStatus.sent,
    successfulContactIds: const ['c1'],
    failedContactIds: const [],
  );
}

class _FakeHistoryRepository implements EmergencyEventRepository {
  _FakeHistoryRepository({
    this.events = const [],
    this.fail = false,
    this.delay = Duration.zero,
  });

  List<EmergencyEvent> events;
  bool fail;
  final Duration delay;

  @override
  Future<EmergencyEvent> createEvent(EmergencyEvent event) async => event;

  @override
  Future<EmergencyEvent> updateEventStatus(
    String eventId,
    EmergencyEventStatus status, {
    String? message,
  }) async => throw UnimplementedError();

  @override
  Future<EmergencyEvent?> getEvent(String eventId) async => null;

  @override
  Future<List<EmergencyEvent>> getEventHistory() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (fail) throw Exception('firestore read failed');
    return events;
  }
}
