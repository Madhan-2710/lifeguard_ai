import 'package:flutter_test/flutter_test.dart';
import 'package:lifeguard_ai/features/sos/data/models/emergency_event_model.dart';
import 'package:lifeguard_ai/features/sos/domain/entities/emergency_alert_delivery.dart';
import 'package:lifeguard_ai/features/sos/domain/entities/emergency_event.dart';

void main() {
  group('EmergencyEventModel delivery fields', () {
    test('fromMap parses delivery fields', () {
      final model = EmergencyEventModel.fromMap(<String, dynamic>{
        'userId': 'user-1',
        'deliveryStatus': 'partiallySent',
        'deliveryStartedAt': '2025-01-01T10:30:00.000',
        'deliveryCompletedAt': '2025-01-01T10:31:00.000',
        'successfulContactIds': ['c1', 'c2'],
        'failedContactIds': ['c3'],
        'deliveryError': 'sms failed for c3',
      }, 'evt-1');

      expect(model.deliveryStatus, EmergencyAlertDeliveryStatus.partiallySent);
      expect(model.deliveryStartedAt, DateTime.parse('2025-01-01T10:30:00.000'));
      expect(
        model.deliveryCompletedAt,
        DateTime.parse('2025-01-01T10:31:00.000'),
      );
      expect(model.successfulContactIds, ['c1', 'c2']);
      expect(model.failedContactIds, ['c3']);
      expect(model.deliveryError, 'sms failed for c3');
    });

    test('fromMap applies defaults for missing delivery fields', () {
      final model = EmergencyEventModel.fromMap(<String, dynamic>{
        'userId': 'user-1',
      }, 'evt-2');

      expect(model.deliveryStatus, EmergencyAlertDeliveryStatus.ready);
      expect(model.deliveryStartedAt, isNull);
      expect(model.deliveryCompletedAt, isNull);
      expect(model.successfulContactIds, isEmpty);
      expect(model.failedContactIds, isEmpty);
      expect(model.deliveryError, isNull);
    });

    test('fromMap falls back to ready for unknown deliveryStatus', () {
      final model = EmergencyEventModel.fromMap(<String, dynamic>{
        'userId': 'user-1',
        'deliveryStatus': 'notARealStatus',
      }, 'evt-3');

      expect(model.deliveryStatus, EmergencyAlertDeliveryStatus.ready);
    });

    test('toMap round-trips delivery fields through fromMap', () {
      final model = EmergencyEventModel(
        id: 'evt-4',
        userId: 'user-1',
        deliveryStatus: EmergencyAlertDeliveryStatus.sent,
        deliveryStartedAt: DateTime(2025, 3, 1, 12, 0),
        deliveryCompletedAt: DateTime(2025, 3, 1, 12, 1),
        successfulContactIds: const ['c1'],
        failedContactIds: const ['c2'],
        deliveryError: 'retry needed',
      );

      final map = model.toMap();
      final restored = EmergencyEventModel.fromMap(map, 'evt-4');

      expect(restored.deliveryStatus, model.deliveryStatus);
      expect(restored.deliveryStartedAt, model.deliveryStartedAt);
      expect(restored.deliveryCompletedAt, model.deliveryCompletedAt);
      expect(restored.successfulContactIds, model.successfulContactIds);
      expect(restored.failedContactIds, model.failedContactIds);
      expect(restored.deliveryError, model.deliveryError);
    });

    test('fromEntity preserves delivery fields', () {
      final entity = EmergencyEvent(
        id: 'evt-5',
        userId: 'user-1',
        deliveryStatus: EmergencyAlertDeliveryStatus.failed,
        deliveryStartedAt: DateTime(2025, 4, 1, 9, 0),
        deliveryCompletedAt: DateTime(2025, 4, 1, 9, 5),
        successfulContactIds: const ['c1'],
        failedContactIds: const ['c2', 'c3'],
        deliveryError: 'all channels failed',
      );

      final model = EmergencyEventModel.fromEntity(entity);

      expect(model.deliveryStatus, entity.deliveryStatus);
      expect(model.deliveryStartedAt, entity.deliveryStartedAt);
      expect(model.deliveryCompletedAt, entity.deliveryCompletedAt);
      expect(model.successfulContactIds, entity.successfulContactIds);
      expect(model.failedContactIds, entity.failedContactIds);
      expect(model.deliveryError, entity.deliveryError);
    });
  });
}
