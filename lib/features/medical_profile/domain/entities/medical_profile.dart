import 'package:equatable/equatable.dart';

/// Medical profile for the authenticated user.
///
/// All fields are user/doctor-entered data. This app never invents dosages,
/// diagnoses, or prescriptions — it only stores what the user or their doctor
/// has entered.
class MedicalProfile extends Equatable {
  const MedicalProfile({
    this.dateOfBirth,
    this.bloodGroup = '',
    this.allergies = const [],
    this.chronicConditions = const [],
    this.currentMedicines = const [],
    this.pastSurgeries = const [],
    this.emergencyMedicalNotes = '',
    this.updatedAt,
  });

  final DateTime? dateOfBirth;
  final String bloodGroup;
  final List<String> allergies;
  final List<String> chronicConditions;
  final List<String> currentMedicines;
  final List<String> pastSurgeries;
  final String emergencyMedicalNotes;
  final DateTime? updatedAt;

  bool get isEmpty =>
      dateOfBirth == null &&
      bloodGroup.isEmpty &&
      allergies.isEmpty &&
      chronicConditions.isEmpty &&
      currentMedicines.isEmpty &&
      pastSurgeries.isEmpty &&
      emergencyMedicalNotes.isEmpty;

  MedicalProfile copyWith({
    DateTime? dateOfBirth,
    String? bloodGroup,
    List<String>? allergies,
    List<String>? chronicConditions,
    List<String>? currentMedicines,
    List<String>? pastSurgeries,
    String? emergencyMedicalNotes,
    DateTime? updatedAt,
  }) {
    return MedicalProfile(
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      currentMedicines: currentMedicines ?? this.currentMedicines,
      pastSurgeries: pastSurgeries ?? this.pastSurgeries,
      emergencyMedicalNotes: emergencyMedicalNotes ?? this.emergencyMedicalNotes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    dateOfBirth,
    bloodGroup,
    allergies,
    chronicConditions,
    currentMedicines,
    pastSurgeries,
    emergencyMedicalNotes,
    updatedAt,
  ];
}
