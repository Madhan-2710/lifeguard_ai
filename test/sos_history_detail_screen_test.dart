import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeguard_ai/core/constants/app_strings.dart';
import 'package:lifeguard_ai/features/sos/domain/entities/emergency_alert_delivery.dart';
import 'package:lifeguard_ai/features/sos/domain/entities/emergency_event.dart';
import 'package:lifeguard_ai/presentation/emergency/sos_history_detail_screen.dart';

void main() {
  group('SosHistoryDetailScreen rendering', () {
    testWidgets('renders event details for a fully populated event', (
      tester,
    ) async {
      final event = _event(
        id: 'evt-123',
        timestamp: DateTime(2025, 3, 10, 14, 45),
        status: EmergencyEventStatus.ready,
        deliveryStatus: EmergencyAlertDeliveryStatus.sent,
        successfulContactIds: const ['c1', 'c2'],
        failedContactIds: const ['c3'],
        latitude: 37.4219999,
        longitude: -122.0840575,
      );

      await tester.pumpWidget(_wrap(event));

      expect(find.text(AppStrings.sosHistoryDetailTitle), findsOneWidget);
      expect(find.text('Mar 10, 2025 - 02:45 PM'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text(AppStrings.sosSentSuccessfully), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('37.42200, -122.08406'), findsOneWidget);
      expect(find.text(AppStrings.sosHistoryDetailOpenMaps), findsOneWidget);
      expect(find.text('evt-123'), findsOneWidget);
    });

    testWidgets('renders sent delivery status', (tester) async {
      final event = _event(
        id: 'e1',
        deliveryStatus: EmergencyAlertDeliveryStatus.sent,
      );

      await tester.pumpWidget(_wrap(event));

      expect(find.text(AppStrings.sosSentSuccessfully), findsOneWidget);
    });

    testWidgets('renders partially sent delivery status', (tester) async {
      final event = _event(
        id: 'e1',
        deliveryStatus: EmergencyAlertDeliveryStatus.partiallySent,
        successfulContactIds: const ['c1'],
        failedContactIds: const ['c2'],
      );

      await tester.pumpWidget(_wrap(event));

      expect(find.text(AppStrings.sosPartiallySent), findsOneWidget);
    });

    testWidgets('renders failed delivery status with delivery error', (
      tester,
    ) async {
      final event = _event(
        id: 'e1',
        deliveryStatus: EmergencyAlertDeliveryStatus.failed,
        deliveryError: 'SMS provider rejected the request',
      );

      await tester.pumpWidget(_wrap(event));

      expect(find.text(AppStrings.sosDeliveryFailed), findsOneWidget);
      expect(find.text(AppStrings.sosHistoryDetailDeliveryError), findsOneWidget);
      expect(find.text('SMS provider rejected the request'), findsOneWidget);
    });

    testWidgets('renders successful and failed contact counts', (tester) async {
      final event = _event(
        id: 'e1',
        successfulContactIds: const ['c1', 'c2', 'c3'],
        failedContactIds: const ['c4', 'c5'],
      );

      await tester.pumpWidget(_wrap(event));

      expect(find.text(AppStrings.sosHistorySuccessful), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text(AppStrings.sosHistoryFailed), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('renders location available with coordinates and maps button', (
      tester,
    ) async {
      final event = _event(
        id: 'e1',
        latitude: 40.7128,
        longitude: -74.0060,
      );

      await tester.pumpWidget(_wrap(event));

      expect(find.text(AppStrings.sosHistoryDetailCoordinates), findsOneWidget);
      expect(find.text('40.71280, -74.00600'), findsOneWidget);
      expect(find.text(AppStrings.sosHistoryDetailOpenMaps), findsOneWidget);
    });

    testWidgets('renders location unavailable without maps button', (
      tester,
    ) async {
      final event = _event(id: 'e1');

      await tester.pumpWidget(_wrap(event));

      expect(find.text(AppStrings.sosHistoryLocationUnavailable), findsOneWidget);
      expect(find.text(AppStrings.sosHistoryDetailOpenMaps), findsNothing);
    });

    testWidgets('handles missing optional fields on old events', (tester) async {
      final event = EmergencyEvent(
        id: 'old-event',
        userId: 'user-1',
      );

      await tester.pumpWidget(_wrap(event));

      expect(find.text(AppStrings.sosHistoryTimeUnavailable), findsOneWidget);
      expect(find.text(AppStrings.sosHistoryLocationUnavailable), findsOneWidget);
      expect(find.text(AppStrings.sosHistoryDetailNoDeliveryData), findsOneWidget);
      expect(find.text('old-event'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

EmergencyEvent _event({
  required String id,
  DateTime? timestamp,
  EmergencyEventStatus status = EmergencyEventStatus.ready,
  EmergencyAlertDeliveryStatus deliveryStatus =
      EmergencyAlertDeliveryStatus.ready,
  List<String> successfulContactIds = const [],
  List<String> failedContactIds = const [],
  double? latitude,
  double? longitude,
  String? deliveryError,
}) {
  return EmergencyEvent(
    id: id,
    userId: 'user-1',
    timestamp: timestamp ?? DateTime(2025, 1, 1, 10, 30),
    latitude: latitude,
    longitude: longitude,
    status: status,
    deliveryStatus: deliveryStatus,
    successfulContactIds: successfulContactIds,
    failedContactIds: failedContactIds,
    deliveryError: deliveryError,
  );
}

Widget _wrap(EmergencyEvent event) {
  return MaterialApp(home: SosHistoryDetailScreen(event: event));
}
