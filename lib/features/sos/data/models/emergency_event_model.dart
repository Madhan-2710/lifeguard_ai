import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../domain/entities/emergency_alert_delivery.dart';
import '../../domain/entities/emergency_event.dart';

/// Firestore (de)serialization for [EmergencyEvent].
class EmergencyEventModel extends EmergencyEvent {
  const EmergencyEventModel({
    required super.id,
    required super.userId,
    super.latitude,
    super.longitude,
    super.timestamp,
    super.locationLink,
    super.contactIds,
    super.status,
    super.message,
    super.deliveryStatus,
    super.deliveryStartedAt,
    super.deliveryCompletedAt,
    super.successfulContactIds,
    super.failedContactIds,
    super.deliveryError,
  });

  factory EmergencyEventModel.fromEntity(EmergencyEvent entity) {
    return EmergencyEventModel(
      id: entity.id,
      userId: entity.userId,
      latitude: entity.latitude,
      longitude: entity.longitude,
      timestamp: entity.timestamp,
      locationLink: entity.locationLink,
      contactIds: entity.contactIds,
      status: entity.status,
      message: entity.message,
      deliveryStatus: entity.deliveryStatus,
      deliveryStartedAt: entity.deliveryStartedAt,
      deliveryCompletedAt: entity.deliveryCompletedAt,
      successfulContactIds: entity.successfulContactIds,
      failedContactIds: entity.failedContactIds,
      deliveryError: entity.deliveryError,
    );
  }

  factory EmergencyEventModel.fromMap(Map<String, dynamic> map, String docId) {
    return EmergencyEventModel(
      id: docId.isNotEmpty
          ? docId
          : (map[FirebaseConstants.alertId]?.toString() ?? ''),
      userId: map['userId']?.toString() ?? '',
      latitude: (map[FirebaseConstants.latitude] as num?)?.toDouble(),
      longitude: (map[FirebaseConstants.longitude] as num?)?.toDouble(),
      timestamp: _parseDateTime(map[FirebaseConstants.timestamp]),
      locationLink: map['locationLink']?.toString(),
      contactIds:
          (map[FirebaseConstants.alertedContacts] as List<dynamic>? ?? const [])
              .map((e) => e.toString())
              .toList(),
      status: EmergencyEventStatus.values.firstWhere(
        (s) => s.name == map[FirebaseConstants.status],
        orElse: () => EmergencyEventStatus.pending,
      ),
      message: map['message']?.toString(),
      deliveryStatus: _parseDeliveryStatus(map['deliveryStatus']),
      deliveryStartedAt: _parseDateTime(map['deliveryStartedAt']),
      deliveryCompletedAt: _parseDateTime(map['deliveryCompletedAt']),
      successfulContactIds: _stringList(map['successfulContactIds']),
      failedContactIds: _stringList(map['failedContactIds']),
      deliveryError: map['deliveryError']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirebaseConstants.alertId: id,
      'userId': userId,
      FirebaseConstants.latitude: latitude,
      FirebaseConstants.longitude: longitude,
      FirebaseConstants.timestamp: timestamp?.toIso8601String(),
      'locationLink': locationLink,
      FirebaseConstants.alertedContacts: contactIds,
      FirebaseConstants.status: status.name,
      'message': message,
      'deliveryStatus': deliveryStatus.name,
      'deliveryStartedAt': deliveryStartedAt?.toIso8601String(),
      'deliveryCompletedAt': deliveryCompletedAt?.toIso8601String(),
      'successfulContactIds': successfulContactIds,
      'failedContactIds': failedContactIds,
      'deliveryError': deliveryError,
      FirebaseConstants.createdAt: DateTime.now().toIso8601String(),
      FirebaseConstants.updatedAt: DateTime.now().toIso8601String(),
    };
  }

  static EmergencyAlertDeliveryStatus _parseDeliveryStatus(dynamic value) {
    return EmergencyAlertDeliveryStatus.values.firstWhere(
      (status) => status.name == value?.toString(),
      orElse: () => EmergencyAlertDeliveryStatus.ready,
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) => item.toString()).toList();
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
