import 'package:equatable/equatable.dart';

/// A medicine the user (or their doctor) has entered.
///
/// Dosage and instructions are user/doctor-entered data only. This app never
/// invents dosages or prescribes medication.
class Medicine extends Equatable {
  const Medicine({
    this.id = '',
    required this.name,
    this.dosage = '',
    this.frequency = '',
    this.reminderTimes = const [],
    this.startDate,
    this.endDate,
    this.prescribedBy = '',
    this.notes = '',
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final List<TimeOfDayValue> reminderTimes;
  final DateTime? startDate;
  final DateTime? endDate;
  final String prescribedBy;
  final String notes;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Medicine copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    List<TimeOfDayValue>? reminderTimes,
    DateTime? startDate,
    DateTime? endDate,
    String? prescribedBy,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      prescribedBy: prescribedBy ?? this.prescribedBy,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    dosage,
    frequency,
    reminderTimes,
    startDate,
    endDate,
    prescribedBy,
    notes,
    isActive,
    createdAt,
    updatedAt,
  ];
}

/// A reminder time of day (hour/minute) that is serializable and comparable.
class TimeOfDayValue extends Equatable {
  const TimeOfDayValue({required this.hour, required this.minute});

  final int hour;
  final int minute;

  String toTimeString() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  List<Object?> get props => [hour, minute];
}
