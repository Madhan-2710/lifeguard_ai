import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeguard_ai/core/constants/app_strings.dart';
import 'package:lifeguard_ai/features/sos/domain/entities/emergency_alert_delivery.dart';
import 'package:lifeguard_ai/features/sos/domain/entities/emergency_event.dart';
import 'package:lifeguard_ai/features/sos/domain/repositories/emergency_event_repository.dart';
import 'package:lifeguard_ai/features/sos/presentation/cubit/sos_history_cubit.dart';
import 'package:lifeguard_ai/features/sos/presentation/cubit/sos_history_state.dart';
import 'package:lifeguard_ai/presentation/emergency/sos_history_screen.dart';

void main() {
  group('SosHistoryView rendering', () {
    testWidgets('renders delivery status label for a sent event',
        (tester) async {
      final cubit = SosHistoryCubit(eventRepository: _FakeRepo());
      cubit.emit(
        SosHistoryState(
          status: SosHistoryStatus.loaded,
          events: [
            _event(
              id: 'e1',
              deliveryStatus: EmergencyAlertDeliveryStatus.sent,
            ),
          ],
        ),
      );

      await tester.pumpWidget(_wrap(cubit));

      expect(find.text(AppStrings.sosSentSuccessfully), findsOneWidget);
      expect(find.text(AppStrings.sosHistoryDeliveryStatus), findsOneWidget);
      cubit.close();
    });

    testWidgets('renders failed delivery status label', (tester) async {
      final cubit = SosHistoryCubit(eventRepository: _FakeRepo());
      cubit.emit(
        SosHistoryState(
          status: SosHistoryStatus.loaded,
          events: [
            _event(
              id: 'e1',
              deliveryStatus: EmergencyAlertDeliveryStatus.failed,
            ),
          ],
        ),
      );

      await tester.pumpWidget(_wrap(cubit));

      expect(find.text(AppStrings.sosDeliveryFailed), findsOneWidget);
      cubit.close();
    });

    testWidgets('renders successful and failed contact counts', (tester) async {
      final cubit = SosHistoryCubit(eventRepository: _FakeRepo());
      cubit.emit(
        SosHistoryState(
          status: SosHistoryStatus.loaded,
          events: [
            _event(
              id: 'e1',
              successfulContactIds: const ['c1', 'c2', 'c3'],
              failedContactIds: const ['c4'],
            ),
          ],
        ),
      );

      await tester.pumpWidget(_wrap(cubit));

      expect(find.text(AppStrings.sosHistorySuccessful), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text(AppStrings.sosHistoryFailed), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      cubit.close();
    });

    testWidgets('hides contact counts when no delivery data exists',
        (tester) async {
      final cubit = SosHistoryCubit(eventRepository: _FakeRepo());
      cubit.emit(
        SosHistoryState(
          status: SosHistoryStatus.loaded,
          events: [_event(id: 'e1')],
        ),
      );

      await tester.pumpWidget(_wrap(cubit));

      expect(find.text(AppStrings.sosHistorySuccessful), findsNothing);
      expect(find.text(AppStrings.sosHistoryFailed), findsNothing);
      cubit.close();
    });

    testWidgets('renders location availability', (tester) async {
      final cubit = SosHistoryCubit(eventRepository: _FakeRepo());
      cubit.emit(
        SosHistoryState(
          status: SosHistoryStatus.loaded,
          events: [
            _event(id: 'with-location', latitude: 1.0, longitude: 2.0),
            _event(id: 'no-location'),
          ],
        ),
      );

      await tester.pumpWidget(_wrap(cubit));

      expect(
        find.text(AppStrings.sosHistoryLocationAvailable),
        findsOneWidget,
      );
      expect(
        find.text(AppStrings.sosHistoryLocationUnavailable),
        findsOneWidget,
      );
      cubit.close();
    });

    testWidgets('renders event status label', (tester) async {
      final cubit = SosHistoryCubit(eventRepository: _FakeRepo());
      cubit.emit(
        SosHistoryState(
          status: SosHistoryStatus.loaded,
          events: [
            _event(id: 'e1', status: EmergencyEventStatus.cancelled),
          ],
        ),
      );

      await tester.pumpWidget(_wrap(cubit));

      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.text(AppStrings.sosHistoryEventStatus), findsOneWidget);
      cubit.close();
    });

    testWidgets('renders empty state', (tester) async {
      final cubit = SosHistoryCubit(eventRepository: _FakeRepo());
      cubit.emit(const SosHistoryState(status: SosHistoryStatus.empty));

      await tester.pumpWidget(_wrap(cubit));

      expect(find.text(AppStrings.sosHistoryEmpty), findsOneWidget);
      cubit.close();
    });

    testWidgets('renders loading state', (tester) async {
      final cubit = SosHistoryCubit(eventRepository: _FakeRepo());
      cubit.emit(const SosHistoryState(status: SosHistoryStatus.loading));

      await tester.pumpWidget(_wrap(cubit));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      cubit.close();
    });

    testWidgets('renders failure state with retry', (tester) async {
      final cubit = SosHistoryCubit(eventRepository: _FakeRepo());
      cubit.emit(
        const SosHistoryState(
          status: SosHistoryStatus.failure,
          message: AppStrings.sosHistoryLoadError,
        ),
      );

      await tester.pumpWidget(_wrap(cubit));

      expect(find.text(AppStrings.sosHistoryLoadError), findsOneWidget);
      expect(find.text(AppStrings.sosHistoryRetry), findsOneWidget);
      cubit.close();
    });
  });
}

EmergencyEvent _event({
  required String id,
  EmergencyEventStatus status = EmergencyEventStatus.ready,
  EmergencyAlertDeliveryStatus deliveryStatus =
      EmergencyAlertDeliveryStatus.ready,
  List<String> successfulContactIds = const [],
  List<String> failedContactIds = const [],
  double? latitude,
  double? longitude,
}) {
  return EmergencyEvent(
    id: id,
    userId: 'user-1',
    timestamp: DateTime(2025, 1, 1, 10, 30),
    latitude: latitude,
    longitude: longitude,
    status: status,
    deliveryStatus: deliveryStatus,
    successfulContactIds: successfulContactIds,
    failedContactIds: failedContactIds,
  );
}

Widget _wrap(SosHistoryCubit cubit) {
  return BlocProvider<SosHistoryCubit>(
    create: (_) => cubit,
    child: const MaterialApp(home: SosHistoryView()),
  );
}

class _FakeRepo implements EmergencyEventRepository {
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
  Future<List<EmergencyEvent>> getEventHistory() async => const [];
}
