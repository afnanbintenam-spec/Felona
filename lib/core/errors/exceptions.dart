/// Base exception class for all application-specific exceptions.
///
/// All custom exceptions in the application should extend this class
/// to provide consistent error handling across the app.
abstract class AppException implements Exception {
  /// Human-readable error message
  final String message;

  /// Optional error code for programmatic error handling
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when network-related errors occur.
///
/// This includes connection timeouts, no internet connection,
/// request cancellations, and other network-level failures.
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);

  @override
  String toString() => 'NetworkException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when authentication fails.
///
/// This includes invalid credentials, missing tokens,
/// and other authentication-related failures.
class AuthenticationException extends AppException {
  const AuthenticationException(super.message, [super.code]);

  @override
  String toString() => 'AuthenticationException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when input validation fails.
///
/// Contains field-level error messages for form validation.
class ValidationException extends AppException {
  /// Map of field names to their validation error messages
  final Map<String, String> fieldErrors;

  const ValidationException(
    super.message,
    this.fieldErrors, [
    super.code,
  ]);

  @override
  String toString() {
    final fieldErrorsStr = fieldErrors.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
    return 'ValidationException: $message${code != null ? ' (code: $code)' : ''}'
        '${fieldErrors.isNotEmpty ? ' [Fields: $fieldErrorsStr]' : ''}';
  }
}

/// Exception thrown when authorization fails.
///
/// This occurs when an authenticated user attempts to access
/// a resource they don't have permission to access.
class AuthorizationException extends AppException {
  const AuthorizationException(super.message, [super.code]);

  @override
  String toString() => 'AuthorizationException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when server-side errors occur.
///
/// This includes 5xx errors and other server-related failures.
class ServerException extends AppException {
  /// HTTP status code if available
  final int? statusCode;

  const ServerException(
    super.message, [
    this.statusCode,
    super.code,
  ]);

  @override
  String toString() => 'ServerException: $message'
      '${statusCode != null ? ' (status: $statusCode)' : ''}'
      '${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when local storage operations fail.
///
/// This includes secure storage read/write failures,
/// cache access errors, and other storage-related issues.
class StorageException extends AppException {
  const StorageException(super.message, [super.code]);

  @override
  String toString() => 'StorageException: $message${code != null ? ' (code: $code)' : ''}';
}
