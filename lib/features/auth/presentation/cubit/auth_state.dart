import 'package:equatable/equatable.dart';

/// The overall authentication status of the user.
enum AuthStatus {
  /// No authentication check has been performed yet.
  initial,

  /// An authentication operation is in progress (login/register/logout/check).
  loading,

  /// The user has successfully signed in.
  authenticated,

  /// The user is not signed in.
  unauthenticated,

  /// A non-login operation succeeded (e.g. password reset email sent).
  success,

  /// The last authentication operation failed.
  failure,
}

/// Immutable state for the [AuthCubit].
class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.message,
    this.onboardingCompleted = false,
  });

  final AuthStatus status;

  /// User-facing error/success message associated with the current status.
  final String? message;

  /// Whether the onboarding flow has been completed locally.
  final bool onboardingCompleted;

  AuthState copyWith({
    AuthStatus? status,
    String? message,
    bool clearMessage = false,
    bool? onboardingCompleted,
  }) {
    return AuthState(
      status: status ?? this.status,
      message: clearMessage ? null : (message ?? this.message),
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  @override
  List<Object?> get props => [status, message, onboardingCompleted];
}