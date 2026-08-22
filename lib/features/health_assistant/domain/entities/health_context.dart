import 'package:equatable/equatable.dart';

/// A compact, safe subset of the authenticated user's medical profile.
///
/// Built by [HealthContextBuilder] from the medical profile and the active
/// medicines list. Contains ONLY information relevant to health guidance:
/// - age/date of birth
/// - blood group
/// - allergies
/// - chronic conditions
/// - current active medicines
/// - emergency medical notes
///
/// It deliberately EXCLUDES email, phone number, passwords, Firebase UID,
/// and any unrelated profile data. It is never logged with sensitive values
/// and is only sent through the intended health-assistant request path.
class HealthContext extends Equatable {
  const HealthContext({
    this.dateOfBirth,
    this.bloodGroup = '',
    this.allergies = const [],
    this.chronicConditions = const [],
    this.currentMedicines = const [],
    this.emergencyMedicalNotes = '',
  });

  final DateTime? dateOfBirth;
  final String bloodGroup;
  final List<String> allergies;
  final List<String> chronicConditions;
  final List<String> currentMedicines;
  final String emergencyMedicalNotes;

  /// Approximate age derived from [dateOfBirth]; null when unknown.
  int? get age {
    final dob = dateOfBirth;
    if (dob == null) return null;
    final now = DateTime.now();
    var years = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      years--;
    }
    return years;
  }

  /// True when no medical information is available at all.
  bool get isEmpty =>
      dateOfBirth == null &&
      bloodGroup.isEmpty &&
      allergies.isEmpty &&
      chronicConditions.isEmpty &&
      currentMedicines.isEmpty &&
      emergencyMedicalNotes.isEmpty;

  bool get hasAllergies => allergies.isNotEmpty;
  bool get hasChronicConditions => chronicConditions.isNotEmpty;
  bool get hasCurrentMedicines => currentMedicines.isNotEmpty;

  /// Renders the context as a compact prompt section for an LLM request.
  ///
  /// Only populated fields are included. No identifiers, contact data, or
  /// unrelated profile information is ever rendered.
  String toPromptSection() {
    final lines = <String>[];
    final computedAge = age;
    if (computedAge != null) lines.add('Age: $computedAge');
    if (bloodGroup.isNotEmpty) lines.add('Blood group: $bloodGroup');
    if (allergies.isNotEmpty) lines.add('Allergies: ${allergies.join(', ')}');
    if (chronicConditions.isNotEmpty) {
      lines.add('Chronic conditions: ${chronicConditions.join(', ')}');
    }
    if (currentMedicines.isNotEmpty) {
      lines.add('Current medicines: ${currentMedicines.join(', ')}');
    }
    if (emergencyMedicalNotes.isNotEmpty) {
      lines.add('Emergency medical notes: $emergencyMedicalNotes');
    }
    return lines.join('\n');
  }

  @override
  List<Object?> get props => [
    dateOfBirth,
    bloodGroup,
    allergies,
    chronicConditions,
    currentMedicines,
    emergencyMedicalNotes,
  ];
}
