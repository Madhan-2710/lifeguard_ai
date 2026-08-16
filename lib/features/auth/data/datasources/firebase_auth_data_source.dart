import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class FirebaseAuthDataSource {
  Future<UserModel?> getCurrentUser();

  Future<bool> isAuthenticated();

  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  });

  Future<void> logout();

  Future<void> forgotPassword({required String email});
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  FirebaseAuthDataSourceImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<UserModel?> getCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return null;
    }

    final snapshot = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(currentUser.uid)
        .get();

    if (snapshot.exists && snapshot.data() != null) {
      return UserModel.fromMap(snapshot.data()!);
    }

    return UserModel.fromFirebaseUser(
      user: currentUser,
      fullName: currentUser.displayName ?? '',
      phoneNumber: currentUser.phoneNumber ?? '',
    );
  }

  @override
  Future<bool> isAuthenticated() async {
    return _auth.currentUser != null;
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthException(
          message: 'Login failed. Please try again.',
          code: 'AUTH_ERROR',
        );
      }

      return UserModel.fromFirebaseUser(
        user: user,
        fullName: user.displayName ?? '',
        phoneNumber: user.phoneNumber ?? '',
      );
    } on FirebaseAuthException catch (exception) {
      throw AuthException(
        message: _mapFirebaseAuthException(exception),
        code: exception.code,
      );
    }
  }

  @override
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthException(
          message: 'Registration failed. Please try again.',
          code: 'AUTH_ERROR',
        );
      }

      await user.updateDisplayName(fullName.trim());

      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? email.trim(),
        fullName: fullName.trim(),
        phoneNumber: phoneNumber.trim(),
        photoUrl: user.photoURL,
        isEmailVerified: user.emailVerified,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (exception) {
      throw AuthException(
        message: _mapFirebaseAuthException(exception),
        code: exception.code,
      );
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (exception) {
      throw AuthException(
        message: _mapFirebaseAuthException(exception),
        code: exception.code,
      );
    }
  }

  String _mapFirebaseAuthException(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is currently disabled.';
      case 'requires-recent-login':
        return 'Please sign in again and try again.';
      default:
        return exception.message ?? 'Authentication failed. Please try again.';
    }
  }
}
