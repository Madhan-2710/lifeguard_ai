import '../entities/user.dart';

abstract class AuthRepository {
  Future<UserEntity?> getCurrentUser();

  Future<bool> isAuthenticated();

  Future<void> login({
    required String email,
    required String password,
  });

  Future<void> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  });

  Future<void> logout();

  Future<void> forgotPassword({required String email});
}
