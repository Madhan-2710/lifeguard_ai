import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/check_authentication_status.dart';
import '../../domain/usecases/forgot_password.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';
import 'auth_state.dart';

/// Cubit that coordinates the Firebase authentication flow.
///
/// All Firebase calls are delegated to the existing domain use cases so the
/// widget layer never talks to Firebase directly. Repository/exception
/// mapping is reused as-is; raw [AppException]s are translated here into
/// user-facing messages.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this._login,
    required this._register,
    required this._logout,
    required this._forgotPassword,
    required this._checkAuthenticationStatus,
  }) : super(const AuthState());

  final Login _login;
  final Register _register;
  final Logout _logout;
  final ForgotPassword _forgotPassword;
  final CheckAuthenticationStatus _checkAuthenticationStatus;

  /// Checks the current Firebase authentication state and the locally stored
  /// onboarding flag. This is invoked from the splash screen.
  Future<void> checkAuthStatus() async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleted =
          prefs.getBool(FirebaseConstants.prefOnboardingComplete) ?? false;

      final isAuthenticated = await _checkAuthenticationStatus(const NoParams());

      if (isAuthenticated) {
        emit(AuthState(
          status: AuthStatus.authenticated,
          onboardingCompleted: onboardingCompleted,
        ));
      } else {
        emit(AuthState(
          status: AuthStatus.unauthenticated,
          onboardingCompleted: onboardingCompleted,
        ));
      }
    } on AppException catch (exception) {
      emit(AuthState(
        status: AuthStatus.failure,
        message: _mapExceptionMessage(exception),
        onboardingCompleted: state.onboardingCompleted,
      ));
    } catch (_) {
      emit(const AuthState(
        status: AuthStatus.failure,
        message: 'Unable to check your session. Please try again.',
      ));
    }
  }

  /// Marks the onboarding flow as complete in local storage.
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(FirebaseConstants.prefOnboardingComplete, true);
    emit(state.copyWith(onboardingCompleted: true));
  }

  /// Signs the user in with email/password using the [Login] use case.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      await _login(LoginParams(email: email, password: password));
      emit(const AuthState(
        status: AuthStatus.authenticated,
        onboardingCompleted: true,
      ));
    } on AppException catch (exception) {
      emit(AuthState(
        status: AuthStatus.failure,
        message: _mapExceptionMessage(exception),
        onboardingCompleted: state.onboardingCompleted,
      ));
    } catch (_) {
      emit(const AuthState(
        status: AuthStatus.failure,
        message: 'Sign in failed. Please try again.',
      ));
    }
  }

  /// Creates the Firebase Auth user and stores the profile in Firestore via
  /// the existing [Register] use case.
  Future<void> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      await _register(RegisterParams(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      ));
      emit(const AuthState(
        status: AuthStatus.authenticated,
        onboardingCompleted: true,
      ));
    } on AppException catch (exception) {
      emit(AuthState(
        status: AuthStatus.failure,
        message: _mapExceptionMessage(exception),
        onboardingCompleted: state.onboardingCompleted,
      ));
    } catch (_) {
      emit(const AuthState(
        status: AuthStatus.failure,
        message: 'Registration failed. Please try again.',
      ));
    }
  }

  /// Sends the Firebase password-reset email via the existing
  /// [ForgotPassword] use case.
  Future<void> forgotPassword({required String email}) async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      await _forgotPassword(ForgotPasswordParams(email: email));
      emit(const AuthState(
        status: AuthStatus.success,
        message: 'Password reset link sent to your email.',
      ));
    } on AppException catch (exception) {
      emit(AuthState(
        status: AuthStatus.failure,
        message: _mapExceptionMessage(exception),
      ));
    } catch (_) {
      emit(const AuthState(
        status: AuthStatus.failure,
        message: 'Unable to send reset email. Please try again.',
      ));
    }
  }

  /// Signs the user out using the existing [Logout] use case.
  Future<void> logout() async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      await _logout(const NoParams());
      emit(const AuthState(
        status: AuthStatus.unauthenticated,
        onboardingCompleted: true,
      ));
    } on AppException catch (exception) {
      emit(AuthState(
        status: AuthStatus.failure,
        message: _mapExceptionMessage(exception),
        onboardingCompleted: state.onboardingCompleted,
      ));
    } catch (_) {
      emit(const AuthState(
        status: AuthStatus.failure,
        message: 'Unable to log out. Please try again.',
      ));
    }
  }

  /// Clears any transient error message from the current state.
  void resetError() {
    if (state.message != null) {
      emit(state.copyWith(clearMessage: true));
    }
  }

  String _mapExceptionMessage(AppException exception) {
    return exception.message.isNotEmpty
        ? exception.message
        : 'Something went wrong. Please try again.';
  }
}