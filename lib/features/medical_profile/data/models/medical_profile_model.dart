import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firebase_constants.dart';
import '../../domain/entities/medical_profile.dart';

/// Firestore model for [MedicalProfile].
///
/// Stored at `users/{uid}/medical_profile/profile`.
class MedicalProfileModel extends MedicalProfile {
  const MedicalProfileModel({
    super.dateOfBirth,
    super.bloodGroup,
    super.allergies,
    super.chronicConditions,
    super.currentMedicines,
    super.pastSurgeries,
    super.emergencyMedicalNotes,
    super.updatedAt,
  });

  factory MedicalProfileModel.fromEntity(MedicalProfile entity) {
    return MedicalProfileModel(
      dateOfBirth: entity.dateOfBirth,
      bloodGroup: entity.bloodGroup,
      allergies: entity.allergies,
      chronicConditions: entity.chronicConditions,
      currentMedicines: entity.currentMedicines,
      pastSurgeries: entity.pastSurgeries,
      emergencyMedicalNotes: entity.emergencyMedicalNotes,
      updatedAt: entity.updatedAt,
    );
  }

  factory MedicalProfileModel.fromMap(Map<String, dynamic> map) {
    return MedicalProfileModel(
      dateOfBirth: _parseDateTime(map[FirebaseConstants.dateOfBirth]),
      bloodGroup: map[FirebaseConstants.bloodGroup]?.toString() ?? '',
      allergies: _parseStringList(map[FirebaseConstants.allergies]),
      chronicConditions:
          _parseStringList(map[FirebaseConstants.chronicConditions]),
      currentMedicines: _parseStringList(map[FirebaseConstants.currentMedicines]),
      pastSurgeries: _parseStringList(map[FirebaseConstants.pastSurgeries]),
      emergencyMedicalNotes:
          map[FirebaseConstants.emergencyMedicalNotes]?.toString() ?? '',
      updatedAt: _parseDateTime(map[FirebaseConstants.updatedAt]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirebaseConstants.dateOfBirth: dateOfBirth?.toIso8601String(),
      FirebaseConstants.bloodGroup: bloodGroup,
      FirebaseConstants.allergies: allergies,
      FirebaseConstants.chronicConditions: chronicConditions,
      FirebaseConstants.currentMedicines: currentMedicines,
      FirebaseConstants.pastSurgeries: pastSurgeries,
      FirebaseConstants.emergencyMedicalNotes: emergencyMedicalNotes,
      FirebaseConstants.updatedAt:
          updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
