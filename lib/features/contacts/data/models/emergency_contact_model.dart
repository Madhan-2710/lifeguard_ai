import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../domain/entities/emergency_contact.dart';

class EmergencyContactModel extends EmergencyContact {
  const EmergencyContactModel({
    required super.id,
    required super.name,
    required super.phoneNumber,
    super.relationship,
    super.isPrimary,
    super.createdAt,
    super.updatedAt,
  });

  factory EmergencyContactModel.fromEntity(EmergencyContact entity) {
    return EmergencyContactModel(
      id: entity.id,
      name: entity.name,
      phoneNumber: entity.phoneNumber,
      relationship: entity.relationship,
      isPrimary: entity.isPrimary,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory EmergencyContactModel.fromMap(
    Map<String, dynamic> map,
    String docId,
  ) {
    return EmergencyContactModel(
      id: docId.isNotEmpty
          ? docId
          : (map[FirebaseConstants.contactId]?.toString() ?? ''),
      name: map[FirebaseConstants.name]?.toString() ?? '',
      phoneNumber: map[FirebaseConstants.phone]?.toString() ?? '',
      relationship: map[FirebaseConstants.relationship]?.toString() ?? 'Other',
      isPrimary: map[FirebaseConstants.isPrimary] as bool? ?? false,
      createdAt: _parseDateTime(map[FirebaseConstants.createdAt]),
      updatedAt: _parseDateTime(map[FirebaseConstants.updatedAt]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirebaseConstants.contactId: id,
      FirebaseConstants.name: name,
      FirebaseConstants.phone: phoneNumber,
      FirebaseConstants.relationship: relationship,
      FirebaseConstants.isPrimary: isPrimary,
      FirebaseConstants.createdAt:
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      FirebaseConstants.updatedAt:
          updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
