import 'package:flutter_test/flutter_test.dart';
import 'package:lifeguard_ai/features/contacts/data/models/emergency_contact_model.dart';
import 'package:lifeguard_ai/features/contacts/domain/entities/emergency_contact.dart';

void main() {
  group('EmergencyContactModel', () {
    test('fromMap parses all fields', () {
      final map = <String, dynamic>{
        'contactId': 'c1',
        'name': 'Jane Doe',
        'phone': '+1 555 123 4567',
        'relationship': 'Spouse',
        'isPrimary': true,
        'createdAt': '2025-01-01T10:00:00.000',
        'updatedAt': '2025-01-02T10:00:00.000',
      };

      final model = EmergencyContactModel.fromMap(map, 'c1');

      expect(model.id, 'c1');
      expect(model.name, 'Jane Doe');
      expect(model.phoneNumber, '+1 555 123 4567');
      expect(model.relationship, 'Spouse');
      expect(model.isPrimary, isTrue);
      expect(model.createdAt, DateTime.parse('2025-01-01T10:00:00.000'));
      expect(model.updatedAt, DateTime.parse('2025-01-02T10:00:00.000'));
    });

    test('fromMap applies defaults for missing optional fields', () {
      final model = EmergencyContactModel.fromMap(<String, dynamic>{
        'name': 'A',
        'phone': '123',
      }, 'c2');

      expect(model.id, 'c2');
      expect(model.relationship, 'Other');
      expect(model.isPrimary, isFalse);
      expect(model.createdAt, isNull);
    });

    test('toMap round-trips through fromMap', () {
      final model = EmergencyContactModel(
        id: 'c3',
        name: 'Bob',
        phoneNumber: '+1 555 000 0000',
        relationship: 'Friend',
        isPrimary: true,
        createdAt: DateTime(2025, 3, 1),
        updatedAt: DateTime(2025, 3, 2),
      );

      final map = model.toMap();
      final restored = EmergencyContactModel.fromMap(map, 'c3');

      expect(restored.id, model.id);
      expect(restored.name, model.name);
      expect(restored.phoneNumber, model.phoneNumber);
      expect(restored.relationship, model.relationship);
      expect(restored.isPrimary, model.isPrimary);
      expect(restored.createdAt, model.createdAt);
      expect(restored.updatedAt, model.updatedAt);
    });

    test('fromEntity preserves entity fields', () {
      final entity = EmergencyContact(
        id: 'c4',
        name: 'Alice',
        phoneNumber: '+1 555 111 2222',
        relationship: 'Sibling',
        isPrimary: false,
        createdAt: DateTime(2025, 4, 1),
      );

      final model = EmergencyContactModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.name, entity.name);
      expect(model.phoneNumber, entity.phoneNumber);
      expect(model.relationship, entity.relationship);
      expect(model.isPrimary, entity.isPrimary);
      expect(model.createdAt, entity.createdAt);
    });
  });
}
