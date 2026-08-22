import 'package:flutter_test/flutter_test.dart';
import 'package:lifeguard_ai/features/health_assistant/domain/services/health_context_builder.dart';
import 'package:lifeguard_ai/features/medical_profile/domain/entities/medical_profile.dart';
import 'package:lifeguard_ai/features/medical_profile/domain/repositories/medical_profile_repository.dart';
import 'package:lifeguard_ai/features/medicine/domain/entities/medicine.dart';
import 'package:lifeguard_ai/features/medicine/domain/repositories/medicines_repository.dart';

void main() {
  group('HealthContextBuilder', () {
    test('builds context from profile and active medicines', () async {
      final builder = HealthContextBuilderImpl(
        medicalProfileRepository: _FakeProfileRepository(
          MedicalProfile(
            dateOfBirth: DateTime(1985, 3, 10),
            bloodGroup: 'O+',
            allergies: const ['penicillin'],
            chronicConditions: const ['diabetes'],
            emergencyMedicalNotes: 'Carries an EpiPen',
          ),
        ),
        medicinesRepository: _FakeMedicinesRepository(const [
          Medicine(id: '1', name: 'Metformin', isActive: true),
          Medicine(id: '2', name: 'Amlodipine', isActive: true),
        ]),
      );

      final context = await builder.build();

      expect(context.isEmpty, isFalse);
      expect(context.bloodGroup, 'O+');
      expect(context.allergies, ['penicillin']);
      expect(context.chronicConditions, ['diabetes']);
      expect(context.currentMedicines, ['Metformin', 'Amlodipine']);
      expect(context.emergencyMedicalNotes, 'Carries an EpiPen');
    });

    test('active medicines included, inactive medicines excluded', () async {
      final builder = HealthContextBuilderImpl(
        medicalProfileRepository: _FakeProfileRepository(
          const MedicalProfile(bloodGroup: 'A+'),
        ),
        medicinesRepository: _FakeMedicinesRepository(const [
          Medicine(id: '1', name: 'Metformin', isActive: true),
          Medicine(id: '2', name: 'Old Medicine', isActive: false),
          Medicine(id: '3', name: 'Amlodipine', isActive: true),
        ]),
      );

      final context = await builder.build();

      expect(context.currentMedicines, ['Metformin', 'Amlodipine']);
      expect(context.currentMedicines, isNot(contains('Old Medicine')));
    });

    test('no profile and no medicines produces an empty context', () async {
      final builder = HealthContextBuilderImpl(
        medicalProfileRepository: _FakeProfileRepository(null),
        medicinesRepository: _FakeMedicinesRepository(const []),
      );

      final context = await builder.build();

      expect(context.isEmpty, isTrue);
    });

    test('missing optional profile fields are handled', () async {
      final builder = HealthContextBuilderImpl(
        medicalProfileRepository: _FakeProfileRepository(
          const MedicalProfile(allergies: ['ibuprofen']),
        ),
        medicinesRepository: _FakeMedicinesRepository(const []),
      );

      final context = await builder.build();

      expect(context.allergies, ['ibuprofen']);
      expect(context.dateOfBirth, isNull);
      expect(context.bloodGroup, isEmpty);
      expect(context.chronicConditions, isEmpty);
      expect(context.currentMedicines, isEmpty);
      expect(context.emergencyMedicalNotes, isEmpty);
    });

    test('profile fetch failure still returns a usable context', () async {
      final builder = HealthContextBuilderImpl(
        medicalProfileRepository: _FailingProfileRepository(),
        medicinesRepository: _FakeMedicinesRepository(const [
          Medicine(id: '1', name: 'Metformin', isActive: true),
        ]),
      );

      final context = await builder.build();

      // No throw; medicines still available.
      expect(context.isEmpty, isFalse);
      expect(context.currentMedicines, ['Metformin']);
      expect(context.allergies, isEmpty);
    });

    test('medicine fetch failure still returns profile context', () async {
      final builder = HealthContextBuilderImpl(
        medicalProfileRepository: _FakeProfileRepository(
          const MedicalProfile(
            bloodGroup: 'B+',
            allergies: ['penicillin'],
            currentMedicines: ['Metformin'],
          ),
        ),
        medicinesRepository: _FailingMedicinesRepository(),
      );

      final context = await builder.build();

      // No throw; profile data still available, medicines fall back to the
      // profile's own current-medicines list.
      expect(context.isEmpty, isFalse);
      expect(context.bloodGroup, 'B+');
      expect(context.allergies, ['penicillin']);
      expect(context.currentMedicines, ['Metformin']);
    });

    test('both profile and medicine fetch fail produces empty context', () async {
      final builder = HealthContextBuilderImpl(
        medicalProfileRepository: _FailingProfileRepository(),
        medicinesRepository: _FailingMedicinesRepository(),
      );

      final context = await builder.build();

      expect(context.isEmpty, isTrue);
    });
  });
}

class _FakeProfileRepository implements MedicalProfileRepository {
  _FakeProfileRepository(this.profile);

  final MedicalProfile? profile;

  @override
  Future<MedicalProfile?> getProfile() async => profile;

  @override
  Future<MedicalProfile> saveProfile(MedicalProfile profile) async => profile;
}

class _FailingProfileRepository implements MedicalProfileRepository {
  @override
  Future<MedicalProfile?> getProfile() async {
    throw Exception('profile fetch failed');
  }

  @override
  Future<MedicalProfile> saveProfile(MedicalProfile profile) async => profile;
}

class _FakeMedicinesRepository implements MedicinesRepository {
  _FakeMedicinesRepository(this.medicines);

  final List<Medicine> medicines;

  @override
  Future<List<Medicine>> getMedicines() async => medicines;

  @override
  Future<Medicine> addMedicine(Medicine medicine) async => medicine;

  @override
  Future<Medicine> updateMedicine(Medicine medicine) async => medicine;

  @override
  Future<void> deleteMedicine(String medicineId) async {}
}

class _FailingMedicinesRepository implements MedicinesRepository {
  @override
  Future<List<Medicine>> getMedicines() async {
    throw Exception('medicine fetch failed');
  }

  @override
  Future<Medicine> addMedicine(Medicine medicine) async => medicine;

  @override
  Future<Medicine> updateMedicine(Medicine medicine) async => medicine;

  @override
  Future<void> deleteMedicine(String medicineId) async {}
}
