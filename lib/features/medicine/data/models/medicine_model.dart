import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firebase_constants.dart';
import '../../domain/entities/medicine.dart';

/// Firestore model for [Medicine].
///
/// Stored at `users/{uid}/medicines/{medicineId}`.
class MedicineModel extends Medicine {
  const MedicineModel({
    super.id,
    required super.name,
    super.dosage,
    super.frequency,
    super.reminderTimes,
    super.startDate,
    super.endDate,
    super.prescribedBy,
    super.notes,
    super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory MedicineModel.fromEntity(Medicine entity) {
    return MedicineModel(
      id: entity.id,
      name: entity.name,
      dosage: entity.dosage,
      frequency: entity.frequency,
      reminderTimes: entity.reminderTimes,
      startDate: entity.startDate,
      endDate: entity.endDate,
      prescribedBy: entity.prescribedBy,
      notes: entity.notes,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory MedicineModel.fromMap(Map<String, dynamic> map, String docId) {
    return MedicineModel(
      id: docId.isNotEmpty
          ? docId
          : (map[FirebaseConstants.medicineId]?.toString() ?? ''),
      name: map[FirebaseConstants.medicineName]?.toString() ?? '',
      dosage: map[FirebaseConstants.dosage]?.toString() ?? '',
      frequency: map[FirebaseConstants.frequency]?.toString() ?? '',
      reminderTimes: _parseReminderTimes(map[FirebaseConstants.reminderTimes]),
      startDate: _parseDateTime(map[FirebaseConstants.startDate]),
      endDate: _parseDateTime(map[FirebaseConstants.endDate]),
      prescribedBy: map[FirebaseConstants.prescribedBy]?.toString() ?? '',
      notes: map[FirebaseConstants.notes]?.toString() ?? '',
      isActive: map[FirebaseConstants.isActive] as bool? ?? true,
      createdAt: _parseDateTime(map[FirebaseConstants.createdAt]),
      updatedAt: _parseDateTime(map[FirebaseConstants.updatedAt]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirebaseConstants.medicineId: id,
      FirebaseConstants.medicineName: name,
      FirebaseConstants.dosage: dosage,
      FirebaseConstants.frequency: frequency,
      FirebaseConstants.reminderTimes: reminderTimes
          .map((t) => {'hour': t.hour, 'minute': t.minute})
          .toList(),
      FirebaseConstants.startDate: startDate?.toIso8601String(),
      FirebaseConstants.endDate: endDate?.toIso8601String(),
      FirebaseConstants.prescribedBy: prescribedBy,
      FirebaseConstants.notes: notes,
      FirebaseConstants.isActive: isActive,
      FirebaseConstants.createdAt:
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      FirebaseConstants.updatedAt:
          updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  static List<TimeOfDayValue> _parseReminderTimes(dynamic value) {
    if (value is List) {
      return value.map((e) {
        if (e is Map) {
          final hour = (e['hour'] as num?)?.toInt() ?? 0;
          final minute = (e['minute'] as num?)?.toInt() ?? 0;
          return TimeOfDayValue(hour: hour, minute: minute);
        }
        if (e is String) {
          final parts = e.split(':');
          if (parts.length == 2) {
            return TimeOfDayValue(
              hour: int.tryParse(parts[0]) ?? 0,
              minute: int.tryParse(parts[1]) ?? 0,
            );
          }
        }
        return const TimeOfDayValue(hour: 0, minute: 0);
      }).toList();
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
