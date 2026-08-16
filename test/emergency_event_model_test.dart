import 'package:flutter_test/flutter_test.dart';
import 'package:lifeguard_ai/features/sos/data/models/emergency_event_model.dart';
import 'package:lifeguard_ai/features/sos/domain/entities/emergency_event.dart';

void main() {
  group('EmergencyEventModel', () {
    test('fromMap parses all fields', () {
      final map = <String, dynamic>{
        'alertId': 'evt-1',
        'userId': 'user-1',
        'latitude': 37.4219999,
        'longitude': -122.0840575,
        'timestamp': '2025-01-01T10:30:00.000',
        'locationLink':
            'https://www.google.com/maps/search/?api=1&query=37.4219999,-122.0840575',
        'alertedContacts': ['c1', 'c2'],
        'status': 'ready',
        'message': 'prepared',
      };

      final model = EmergencyEventModel.fromMap(map, 'evt-1');

      expect(model.id, 'evt-1');
      expect(model.userId, 'user-1');
      expect(model.latitude, 37.4219999);
      expect(model.longitude, -122.0840575);
      expect(model.timestamp, DateTime.parse('2025-01-01T10:30:00.000'));
      expect(model.locationLink, isNotNull);
      expect(model.contactIds, ['c1', 'c2']);
      expect(model.status, EmergencyEventStatus.ready);
      expect(model.message, 'prepared');
    });

    test('fromMap applies defaults for missing optional fields', () {
      final model = EmergencyEventModel.fromMap(<String, dynamic>{
        'userId': 'user-1',
      }, 'evt-2');

      expect(model.id, 'evt-2');
      expect(model.latitude, isNull);
      expect(model.longitude, isNull);
      expect(model.timestamp, isNull);
      expect(model.contactIds, isEmpty);
      expect(model.status, EmergencyEventStatus.pending);
    });

    test('fromMap falls back to alertId field when docId is empty', () {
      final model = EmergencyEventModel.fromMap(<String, dynamic>{
        'alertId': 'evt-3',
        'userId': 'user-1',
      }, '');

      expect(model.id, 'evt-3');
    });

    test('toMap round-trips through fromMap', () {
      final model = EmergencyEventModel(
        id: 'evt-4',
        userId: 'user-1',
        latitude: 10.5,
        longitude: 20.25,
        timestamp: DateTime(2025, 3, 1, 12, 0),
        locationLink: 'https://maps.example/10.5,20.25',
        contactIds: const ['c1'],
        status: EmergencyEventStatus.ready,
        message: 'ok',
      );

      final map = model.toMap();
      final restored = EmergencyEventModel.fromMap(map, 'evt-4');

      expect(restored.id, model.id);
      expect(restored.userId, model.userId);
      expect(restored.latitude, model.latitude);
      expect(restored.longitude, model.longitude);
      expect(restored.timestamp, model.timestamp);
      expect(restored.locationLink, model.locationLink);
      expect(restored.contactIds, model.contactIds);
      expect(restored.status, model.status);
      expect(restored.message, model.message);
    });

    test('fromEntity preserves entity fields', () {
      final entity = EmergencyEvent(
        id: 'evt-5',
        userId: 'user-1',
        latitude: 1.0,
        longitude: 2.0,
        timestamp: DateTime(2025, 4, 1),
        locationLink: 'https://maps.example/1.0,2.0',
        contactIds: const ['c1', 'c2'],
        status: EmergencyEventStatus.cancelled,
        message: 'cancelled by user',
      );

      final model = EmergencyEventModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.userId, entity.userId);
      expect(model.latitude, entity.latitude);
      expect(model.longitude, entity.longitude);
      expect(model.timestamp, entity.timestamp);
      expect(model.locationLink, entity.locationLink);
      expect(model.contactIds, entity.contactIds);
      expect(model.status, entity.status);
      expect(model.message, entity.message);
    });
  });
}
