/// Base exception class for LifeGuard AI
class AppException implements Exception {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  AppException({
    required this.message,
    this.code,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Exception thrown when there's a network connectivity issue
class NetworkException extends AppException {
  NetworkException({
    super.message = 'No internet connection. Please check your network settings.',
    super.code = 'NETWORK_ERROR',
    super.stackTrace,
  });
}

/// Exception thrown when a server error occurs
class ServerException extends AppException {
  ServerException({
    super.message = 'Server error occurred. Please try again later.',
    super.code = 'SERVER_ERROR',
    super.stackTrace,
  });
}

/// Exception thrown when authentication fails
class AuthException extends AppException {
  AuthException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Exception thrown when user input is invalid
class ValidationException extends AppException {
  ValidationException({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    super.stackTrace,
  });
}

/// Exception thrown when a resource is not found
class NotFoundException extends AppException {
  NotFoundException({
    super.message = 'Resource not found',
    super.code = 'NOT_FOUND',
    super.stackTrace,
  });
}

/// Exception thrown when the user doesn't have permission
class PermissionException extends AppException {
  PermissionException({
    required super.message,
    super.code = 'PERMISSION_DENIED',
    super.stackTrace,
  });
}

/// Exception thrown when a cache operation fails
class CacheException extends AppException {
  CacheException({
    super.message = 'Cache operation failed',
    super.code = 'CACHE_ERROR',
    super.stackTrace,
  });
}

/// Exception thrown when sensor data is unavailable
class SensorException extends AppException {
  SensorException({
    super.message = 'Sensor data unavailable',
    super.code = 'SENSOR_ERROR',
    super.stackTrace,
  });
}

/// Exception thrown when location services fail
class LocationException extends AppException {
  LocationException({
    super.message = 'Unable to get current location',
    super.code = 'LOCATION_ERROR',
    super.stackTrace,
  });
}

/// Exception thrown when SMS sending fails
class SmsException extends AppException {
  SmsException({
    super.message = 'Failed to send SMS',
    super.code = 'SMS_ERROR',
    super.stackTrace,
  });
}

/// Exception thrown when Firebase operations fail
class FirebaseException extends AppException {
  FirebaseException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Exception thrown when AI model operations fail
class ModelException extends AppException {
  ModelException({
    super.message = 'AI model failed to process request',
    super.code = 'MODEL_ERROR',
    super.stackTrace,
  });
}
