import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final FirebaseAuthDataSource _dataSource;

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      return await _dataSource.getCurrentUser();
    } on AuthException {
      rethrow;
    } catch (_) {
      throw AuthException(
        message: 'Unable to load the current user profile.',
        code: 'AUTH_ERROR',
      );
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      return await _dataSource.isAuthenticated();
    } on AuthException {
      rethrow;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final emailError = Validators.validateEmail(email);
      if (emailError != null) {
        throw ValidationException(message: emailError);
      }

      final passwordError = Validators.validatePassword(password);
      if (passwordError != null) {
        throw ValidationException(message: passwordError);
      }

      await _dataSource.login(
        email: email.trim(),
        password: password,
      );
    } on ValidationException {
      rethrow;
    } on AuthException {
      rethrow;
    } on FirebaseException {
      throw AuthException(
        message: 'Authentication service is unavailable right now.',
        code: 'AUTH_SERVICE_ERROR',
      );
    } catch (_) {
      // Unknown error: do not misreport it as "invalid credentials".
      throw AuthException(
        message: 'Sign in failed. Please try again.',
        code: 'LOGIN_ERROR',
      );
    }
  }

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final fullNameError = Validators.validateFullName(fullName);
      if (fullNameError != null) {
        throw ValidationException(message: fullNameError);
      }

      final emailError = Validators.validateEmail(email);
      if (emailError != null) {
        throw ValidationException(message: emailError);
      }

      final phoneError = Validators.validatePhoneNumber(phoneNumber);
      if (phoneError != null) {
        throw ValidationException(message: phoneError);
      }

      final passwordError = Validators.validatePassword(password);
      if (passwordError != null) {
        throw ValidationException(message: passwordError);
      }

      await _dataSource.register(
        fullName: fullName.trim(),
        email: email.trim(),
        phoneNumber: phoneNumber.trim(),
        password: password,
      );
    } on ValidationException {
      rethrow;
    } on AuthException {
      rethrow;
    } on FirebaseException {
      throw AuthException(
        message: 'Registration service is unavailable right now.',
        code: 'AUTH_SERVICE_ERROR',
      );
    } catch (_) {
      // Unknown error: do not misreport it as "email already in use".
      throw AuthException(
        message: 'Registration failed. Please try again.',
        code: 'REGISTRATION_ERROR',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dataSource.logout();
    } on AuthException {
      rethrow;
    } catch (_) {
      throw AuthException(
        message: 'Unable to log out. Please try again.',
        code: 'LOGOUT_ERROR',
      );
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      final emailError = Validators.validateEmail(email);
      if (emailError != null) {
        throw ValidationException(message: emailError);
      }

      await _dataSource.forgotPassword(email: email.trim());
    } on ValidationException {
      rethrow;
    } on AuthException {
      rethrow;
    } on FirebaseException {
      throw AuthException(
        message: 'Unable to send reset email right now.',
        code: 'PASSWORD_RESET_ERROR',
      );
    } catch (_) {
      // Unknown error: do not misreport it as "user not found".
      throw AuthException(
        message: 'Unable to send reset email. Please try again.',
        code: 'PASSWORD_RESET_ERROR',
      );
    }
  }
}
