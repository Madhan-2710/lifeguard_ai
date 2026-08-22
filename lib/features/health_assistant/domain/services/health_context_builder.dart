import '../../../medical_profile/domain/entities/medical_profile.dart';
import '../../../medical_profile/domain/repositories/medical_profile_repository.dart';
import '../../../medicine/domain/repositories/medicines_repository.dart';
import '../entities/health_context.dart';

/// Builds a compact, safe [HealthContext] for the authenticated user.
///
/// Reads the medical profile and the active medicines and maps them into the
/// minimal context used by the AI Health Assistant. Failures are contained:
/// if the profile or the medicine list cannot be loaded, the builder returns
/// whatever it could load (possibly an empty context) instead of throwing, so
/// the chatbot always keeps working without profile context.
abstract class HealthContextBuilder {
  Future<HealthContext> build();
}

class HealthContextBuilderImpl implements HealthContextBuilder {
  HealthContextBuilderImpl({
    required this._medicalProfileRepository,
    required this._medicinesRepository,
  });

  final MedicalProfileRepository _medicalProfileRepository;
  final MedicinesRepository _medicinesRepository;

  @override
  Future<HealthContext> build() async {
    MedicalProfile? profile;
    try {
      profile = await _medicalProfileRepository.getProfile();
    } catch (_) {
      // Profile unavailable → the assistant works without profile context.
      profile = null;
    }

    List<String> activeMedicines = const [];
    try {
      final medicines = await _medicinesRepository.getMedicines();
      activeMedicines = medicines
          .where((m) => m.isActive)
          .map((m) => m.name.trim())
          .where((n) => n.isNotEmpty)
          .toList();
    } catch (_) {
      // Medicine list unavailable → keep whatever the profile provides.
      activeMedicines = const [];
    }

    // If the medicine list is unavailable (or has no active entries), fall
    // back to the profile's own current-medicines list so the context stays
    // useful.
    if (activeMedicines.isEmpty && profile != null) {
      activeMedicines = profile.currentMedicines;
    }

    if (profile == null) {
      return HealthContext(currentMedicines: activeMedicines);
    }

    return HealthContext(
      dateOfBirth: profile.dateOfBirth,
      bloodGroup: profile.bloodGroup,
      allergies: profile.allergies,
      chronicConditions: profile.chronicConditions,
      currentMedicines: activeMedicines,
      emergencyMedicalNotes: profile.emergencyMedicalNotes,
    );
  }
}
