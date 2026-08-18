import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/emergency_alert_delivery.dart';
import '../../domain/entities/emergency_event.dart';
import '../models/emergency_event_model.dart';

/// Data source for emergency (SOS) events.
///
/// Events are stored privately per user under:
///   users/{userId}/sos_alerts/{eventId}
abstract class EmergencyEventDataSource {
  Future<EmergencyEventModel> createEvent(EmergencyEventModel event);
  Future<EmergencyEventModel> updateEventStatus(
    String eventId,
    EmergencyEventStatus status, {
    String? message,
    EmergencyAlertDeliveryStatus? deliveryStatus,
    DateTime? deliveryStartedAt,
    DateTime? deliveryCompletedAt,
    List<String>? successfulContactIds,
    List<String>? failedContactIds,
    String? deliveryError,
  });
  Future<EmergencyEventModel?> getEvent(String eventId);

  /// Fetches all events stored under `users/{userId}/sos_alerts`.
  ///
  /// Documents are parsed with [EmergencyEventModel.fromMap], which applies
  /// safe defaults for malformed or missing optional fields, so a single bad
  /// document never fails the whole history read.
  Future<List<EmergencyEventModel>> getEventHistory();
}

class EmergencyEventDataSourceImpl implements EmergencyEventDataSource {
  EmergencyEventDataSourceImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  String get _currentUserId => _auth.currentUser?.uid ?? 'local_user';

  CollectionReference<Map<String, dynamic>> get _userEventsRef {
    final uid = _currentUserId;
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .collection(FirebaseConstants.sosAlertsCollection);
  }

  @override
  Future<EmergencyEventModel> createEvent(EmergencyEventModel event) async {
    try {
      final docRef = event.id.isNotEmpty
          ? _userEventsRef.doc(event.id)
          : _userEventsRef.doc();

      final model = EmergencyEventModel(
        id: docRef.id,
        userId: _currentUserId,
        latitude: event.latitude,
        longitude: event.longitude,
        timestamp: event.timestamp,
        locationLink: event.locationLink,
        contactIds: event.contactIds,
        status: event.status,
        message: event.message,
        deliveryStatus: event.deliveryStatus,
        deliveryStartedAt: event.deliveryStartedAt,
        deliveryCompletedAt: event.deliveryCompletedAt,
        successfulContactIds: event.successfulContactIds,
        failedContactIds: event.failedContactIds,
        deliveryError: event.deliveryError,
      );

      await docRef.set(model.toMap());
      return model;
    } catch (e) {
      throw ServerException(message: 'Failed to create emergency event: $e');
    }
  }

  @override
  Future<EmergencyEventModel> updateEventStatus(
    String eventId,
    EmergencyEventStatus status, {
    String? message,
    EmergencyAlertDeliveryStatus? deliveryStatus,
    DateTime? deliveryStartedAt,
    DateTime? deliveryCompletedAt,
    List<String>? successfulContactIds,
    List<String>? failedContactIds,
    String? deliveryError,
  }) async {
    try {
      final data = <String, dynamic>{
        FirebaseConstants.status: status.name,
        FirebaseConstants.updatedAt: DateTime.now().toIso8601String(),
        'message': ?message,
        if (deliveryStatus != null) 'deliveryStatus': deliveryStatus.name,
        if (deliveryStartedAt != null)
          'deliveryStartedAt': deliveryStartedAt.toIso8601String(),
        if (deliveryCompletedAt != null)
          'deliveryCompletedAt': deliveryCompletedAt.toIso8601String(),
      };
      if (successfulContactIds != null) {
        data['successfulContactIds'] = successfulContactIds;
      }
      if (failedContactIds != null) {
        data['failedContactIds'] = failedContactIds;
      }
      if (deliveryError != null) {
        data['deliveryError'] = deliveryError;
      }
      await _userEventsRef.doc(eventId).update(data);
      final doc = await _userEventsRef.doc(eventId).get();
      return EmergencyEventModel.fromMap(doc.data() ?? {}, doc.id);
    } catch (e) {
      throw ServerException(message: 'Failed to update emergency event: $e');
    }
  }

  @override
  Future<EmergencyEventModel?> getEvent(String eventId) async {
    try {
      final doc = await _userEventsRef.doc(eventId).get();
      if (!doc.exists) return null;
      return EmergencyEventModel.fromMap(doc.data() ?? {}, doc.id);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch emergency event: $e');
    }
  }

  @override
  Future<List<EmergencyEventModel>> getEventHistory() async {
    try {
      final snapshot = await _userEventsRef.get();
      return snapshot.docs
          .map((doc) => EmergencyEventModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch emergency event history: $e',
      );
    }
  }
}
