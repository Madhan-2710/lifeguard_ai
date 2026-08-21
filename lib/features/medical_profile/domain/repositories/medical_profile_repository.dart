import '../entities/medical_profile.dart';

/// Repository for the authenticated user's medical profile.
abstract class MedicalProfileRepository {
  Future<MedicalProfile?> getProfile();
  Future<MedicalProfile> saveProfile(MedicalProfile profile);
}
