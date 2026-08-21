import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/medical_profile_model.dart';

/// Data source for the authenticated user's medical profile.
///
/// Storage path: `users/{uid}/medical_profile/profile`.
abstract class MedicalProfileDataSource {
  Future<MedicalProfileModel?> getProfile();
  Future<MedicalProfileModel> saveProfile(MedicalProfileModel profile);
}

class MedicalProfileDataSourceImpl implements MedicalProfileDataSource {
  MedicalProfileDataSourceImpl({
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

  DocumentReference<Map<String, dynamic>> get _profileRef {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(_currentUserId)
        .collection(FirebaseConstants.medicalProfileCollection)
        .doc(FirebaseConstants.medicalProfileDoc);
  }

  @override
  Future<MedicalProfileModel?> getProfile() async {
    try {
      final snapshot = await _profileRef.get();
      if (!snapshot.exists) return null;
      return MedicalProfileModel.fromMap(snapshot.data() ?? {});
    } catch (e) {
      throw ServerException(message: 'Failed to load medical profile: $e');
    }
  }

  @override
  Future<MedicalProfileModel> saveProfile(MedicalProfileModel profile) async {
    try {
      final model = MedicalProfileModel(
        dateOfBirth: profile.dateOfBirth,
        bloodGroup: profile.bloodGroup,
        allergies: profile.allergies,
        chronicConditions: profile.chronicConditions,
        currentMedicines: profile.currentMedicines,
        pastSurgeries: profile.pastSurgeries,
        emergencyMedicalNotes: profile.emergencyMedicalNotes,
        updatedAt: DateTime.now(),
      );
      await _profileRef.set(model.toMap());
      return model;
    } catch (e) {
      throw ServerException(message: 'Failed to save medical profile: $e');
    }
  }
}
