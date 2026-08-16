import 'package:equatable/equatable.dart';

/// Base failure class for LifeGuard AI
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Failure due to network connectivity issues
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network settings.',
    super.code = 'NETWORK_ERROR',
  });
}

/// Failure due to server errors
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error occurred. Please try again later.',
    super.code = 'SERVER_ERROR',
  });
}

/// Failure due to authentication issues
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });

  factory AuthFailure.invalidCredentials() => const AuthFailure(
        message: 'Invalid email or password',
        code: 'INVALID_CREDENTIALS',
      );

  factory AuthFailure.emailAlreadyInUse() => const AuthFailure(
        message: 'An account with this email already exists',
        code: 'EMAIL_IN_USE',
      );

  factory AuthFailure.weakPassword() => const AuthFailure(
        message: 'Password is too weak. Use at least 6 characters',
        code: 'WEAK_PASSWORD',
      );

  factory AuthFailure.userNotFound() => const AuthFailure(
        message: 'No account found with this email',
        code: 'USER_NOT_FOUND',
      );

  factory AuthFailure.tooManyRequests() => const AuthFailure(
        message: 'Too many login attempts. Please try again later.',
        code: 'TOO_MANY_REQUESTS',
      );
}

/// Failure due to invalid input
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
  });
}

/// Failure when a resource is not found
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Resource not found',
    super.code = 'NOT_FOUND',
  });
}

/// Failure due to permission issues
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code = 'PERMISSION_DENIED',
  });
}

/// Failure due to cache issues
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Cache operation failed',
    super.code = 'CACHE_ERROR',
  });
}

/// Failure due to sensor issues
class SensorFailure extends Failure {
  const SensorFailure({
    super.message = 'Sensor data unavailable',
    super.code = 'SENSOR_ERROR',
  });
}

/// Failure due to location issues
class LocationFailure extends Failure {
  const LocationFailure({
    super.message = 'Unable to get current location',
    super.code = 'LOCATION_ERROR',
  });
}

/// Failure due to SMS issues
class SmsFailure extends Failure {
  const SmsFailure({
    super.message = 'Failed to send SMS',
    super.code = 'SMS_ERROR',
  });
}

/// Failure due to Firebase issues
class FirebaseFailure extends Failure {
  const FirebaseFailure({
    required super.message,
    super.code,
  });
}

/// Failure due to AI model issues
class ModelFailure extends Failure {
  const ModelFailure({
    super.message = 'AI model failed to process request',
    super.code = 'MODEL_ERROR',
  });
}

/// General unexpected failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred',
    super.code = 'UNEXPECTED_ERROR',
  });
}
