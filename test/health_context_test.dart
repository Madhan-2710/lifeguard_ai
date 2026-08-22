import 'package:flutter_test/flutter_test.dart';
import 'package:lifeguard_ai/features/health_assistant/domain/entities/health_context.dart';

void main() {
  group('HealthContext', () {
    test('creates a context with all safe medical fields', () {
      final context = HealthContext(
        dateOfBirth: DateTime(1990, 5, 15),
        bloodGroup: 'O+',
        allergies: const ['penicillin', 'ibuprofen'],
        chronicConditions: const ['asthma'],
        currentMedicines: const ['Metformin', 'Amlodipine'],
        emergencyMedicalNotes: 'Carries an EpiPen',
      );

      expect(context.dateOfBirth, DateTime(1990, 5, 15));
      expect(context.bloodGroup, 'O+');
      expect(context.allergies, ['penicillin', 'ibuprofen']);
      expect(context.chronicConditions, ['asthma']);
      expect(context.currentMedicines, ['Metformin', 'Amlodipine']);
      expect(context.emergencyMedicalNotes, 'Carries an EpiPen');
      expect(context.isEmpty, isFalse);
      expect(context.hasAllergies, isTrue);
      expect(context.hasChronicConditions, isTrue);
      expect(context.hasCurrentMedicines, isTrue);
    });

    test('empty profile context is empty', () {
      const context = HealthContext();
      expect(context.isEmpty, isTrue);
      expect(context.hasAllergies, isFalse);
      expect(context.hasChronicConditions, isFalse);
      expect(context.hasCurrentMedicines, isFalse);
      expect(context.age, isNull);
      expect(context.toPromptSection(), isEmpty);
    });

    test('missing optional fields are handled gracefully', () {
      const context = HealthContext(
        bloodGroup: 'A+',
        allergies: ['penicillin'],
      );

      expect(context.isEmpty, isFalse);
      expect(context.dateOfBirth, isNull);
      expect(context.age, isNull);
      expect(context.chronicConditions, isEmpty);
      expect(context.currentMedicines, isEmpty);
      expect(context.emergencyMedicalNotes, isEmpty);
      expect(context.hasAllergies, isTrue);
      expect(context.hasChronicConditions, isFalse);
      expect(context.hasCurrentMedicines, isFalse);
    });

    test('allergy context is included', () {
      const context = HealthContext(allergies: ['ibuprofen', 'penicillin']);
      expect(context.hasAllergies, isTrue);
      expect(context.allergies, contains('ibuprofen'));
      expect(context.toPromptSection(), contains('Allergies: ibuprofen, penicillin'));
    });

    test('chronic condition context is included', () {
      const context = HealthContext(chronicConditions: ['diabetes', 'hypertension']);
      expect(context.hasChronicConditions, isTrue);
      expect(context.toPromptSection(), contains('Chronic conditions: diabetes, hypertension'));
    });

    test('age is derived from date of birth', () {
      final context = HealthContext(dateOfBirth: DateTime(2000, 1, 1));
      final age = context.age;
      expect(age, isNotNull);
      expect(age, greaterThanOrEqualTo(24));
    });

    test('prompt section never includes email, phone, or uid', () {
      const context = HealthContext(
        bloodGroup: 'B+',
        allergies: ['penicillin'],
        currentMedicines: ['Metformin'],
      );
      final section = context.toPromptSection();
      expect(section, isNot(contains('email')));
      expect(section, isNot(contains('phone')));
      expect(section, isNot(contains('uid')));
      expect(section, isNot(contains('password')));
      expect(section, contains('Blood group: B+'));
      expect(section, contains('Allergies: penicillin'));
      expect(section, contains('Current medicines: Metformin'));
    });

    test('prompt section omits empty fields', () {
      const context = HealthContext(bloodGroup: 'O-');
      final section = context.toPromptSection();
      expect(section, contains('Blood group: O-'));
      expect(section, isNot(contains('Allergies')));
      expect(section, isNot(contains('Chronic')));
      expect(section, isNot(contains('Current medicines')));
    });
  });
}
