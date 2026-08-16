import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../../core/constants/firebase_constants.dart';
import '../../domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.fullName,
    super.phoneNumber,
    super.photoUrl,
    super.isEmailVerified,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      fullName: entity.fullName,
      phoneNumber: entity.phoneNumber,
      photoUrl: entity.photoUrl,
      isEmailVerified: entity.isEmailVerified,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory UserModel.fromFirebaseUser({
    required firebase_auth.User user,
    String? fullName,
    String? phoneNumber,
  }) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      fullName: user.displayName ?? fullName ?? '',
      phoneNumber: user.phoneNumber ?? phoneNumber ?? '',
      photoUrl: user.photoURL,
      isEmailVerified: user.emailVerified,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map[FirebaseConstants.userId]?.toString() ?? '',
      email: map[FirebaseConstants.email]?.toString() ?? '',
      fullName: map[FirebaseConstants.fullName]?.toString() ?? '',
      phoneNumber: map[FirebaseConstants.phoneNumber]?.toString() ?? '',
      photoUrl: map[FirebaseConstants.photoUrl]?.toString(),
      isEmailVerified: map['isEmailVerified'] as bool? ?? false,
      createdAt: _parseDateTime(map[FirebaseConstants.createdAt]),
      updatedAt: _parseDateTime(map[FirebaseConstants.updatedAt]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirebaseConstants.userId: id,
      FirebaseConstants.email: email,
      FirebaseConstants.fullName: fullName,
      FirebaseConstants.phoneNumber: phoneNumber,
      FirebaseConstants.photoUrl: photoUrl,
      'isEmailVerified': isEmailVerified,
      FirebaseConstants.createdAt: createdAt?.toIso8601String(),
      FirebaseConstants.updatedAt: updatedAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}
