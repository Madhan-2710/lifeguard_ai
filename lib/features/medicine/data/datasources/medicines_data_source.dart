import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/medicine_model.dart';

/// Data source for the authenticated user's medicines.
///
/// Storage path: `users/{uid}/medicines/{medicineId}`.
abstract class MedicinesDataSource {
  Future<List<MedicineModel>> getMedicines();
  Future<MedicineModel> addMedicine(MedicineModel medicine);
  Future<MedicineModel> updateMedicine(MedicineModel medicine);
  Future<void> deleteMedicine(String medicineId);
}

class MedicinesDataSourceImpl implements MedicinesDataSource {
  MedicinesDataSourceImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  String get _currentUserId {
    final user = _auth.currentUser;
    return user?.uid ?? 'local_user';
  }

  CollectionReference<Map<String, dynamic>> get _medicinesRef {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(_currentUserId)
        .collection(FirebaseConstants.medicinesCollection);
  }

  @override
  Future<List<MedicineModel>> getMedicines() async {
    try {
      final snapshot = await _medicinesRef
          .orderBy(FirebaseConstants.createdAt, descending: false)
          .get();
      return snapshot.docs
          .map((doc) => MedicineModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to load medicines: $e');
    }
  }

  @override
  Future<MedicineModel> addMedicine(MedicineModel medicine) async {
    try {
      final docRef = medicine.id.isNotEmpty
          ? _medicinesRef.doc(medicine.id)
          : _medicinesRef.doc();
      final model = MedicineModel(
        id: docRef.id,
        name: medicine.name,
        dosage: medicine.dosage,
        frequency: medicine.frequency,
        reminderTimes: medicine.reminderTimes,
        startDate: medicine.startDate,
        endDate: medicine.endDate,
        prescribedBy: medicine.prescribedBy,
        notes: medicine.notes,
        isActive: medicine.isActive,
        createdAt: medicine.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await docRef.set(model.toMap());
      return model;
    } catch (e) {
      throw ServerException(message: 'Failed to add medicine: $e');
    }
  }

  @override
  Future<MedicineModel> updateMedicine(MedicineModel medicine) async {
    try {
      final model = MedicineModel(
        id: medicine.id,
        name: medicine.name,
        dosage: medicine.dosage,
        frequency: medicine.frequency,
        reminderTimes: medicine.reminderTimes,
        startDate: medicine.startDate,
        endDate: medicine.endDate,
        prescribedBy: medicine.prescribedBy,
        notes: medicine.notes,
        isActive: medicine.isActive,
        createdAt: medicine.createdAt,
        updatedAt: DateTime.now(),
      );
      await _medicinesRef.doc(medicine.id).set(model.toMap());
      return model;
    } catch (e) {
      throw ServerException(message: 'Failed to update medicine: $e');
    }
  }

  @override
  Future<void> deleteMedicine(String medicineId) async {
    try {
      await _medicinesRef.doc(medicineId).delete();
    } catch (e) {
      throw ServerException(message: 'Failed to delete medicine: $e');
    }
  }
}
