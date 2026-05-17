import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
///
/// Failures represent domain-level errors that are returned from
/// repositories and use cases. They are transformed from exceptions
/// at the data layer boundary.
///
/// Uses Equatable for value equality comparison in tests.
abstract class Failure extends Equatable {
  /// Human-readable error message suitable for display to users
  final String message;

  /// Optional error code for programmatic error handling
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'Failure: $message${code != null ? ' (code: $code)' : ''}';
}

/// Failure representing network-related errors.
///
/// This includes connection timeouts, no internet connection,
/// request cancellations, and other network-level failures.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.code]);

  @override
  String toString() => 'NetworkFailure: $message${code != null ? ' (code: $code)' : ''}';
}

/// Failure representing authentication errors.
///
/// This includes invalid credentials, missing tokens,
/// expired sessions, and other authentication-related failures.
class AuthFailure extends Failure {
  const AuthFailure(super.message, [super.code]);

  @override
  String toString() => 'AuthFailure: $message${code != null ? ' (code: $code)' : ''}';
}

/// Failure representing input validation errors.
///
/// Contains field-level error messages for form validation.
class ValidationFailure extends Failure {
  /// Map of field names to their validation error messages
  final Map<String, String> fieldErrors;

  const ValidationFailure(
    super.message,
    this.fieldErrors, [
    super.code,
  ]);

  @override
  List<Object?> get props => [message, code, fieldErrors];

  @override
  String toString() {
    final fieldErrorsStr = fieldErrors.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
    return 'ValidationFailure: $message${code != null ? ' (code: $code)' : ''}'
        '${fieldErrors.isNotEmpty ? ' [Fields: $fieldErrorsStr]' : ''}';
  }
}

/// Failure representing authorization errors.
///
/// This occurs when an authenticated user attempts to access
/// a resource they don't have permission to access.
class AuthorizationFailure extends Failure {
  const AuthorizationFailure(super.message, [super.code]);

  @override
  String toString() => 'AuthorizationFailure: $message${code != null ? ' (code: $code)' : ''}';
}

/// Failure representing server-side errors.
///
/// This includes 5xx errors and other server-related failures.
class ServerFailure extends Failure {
  /// HTTP status code if available
  final int? statusCode;

  const ServerFailure(
    super.message, [
    this.statusCode,
    super.code,
  ]);

  @override
  List<Object?> get props => [message, code, statusCode];

  @override
  String toString() => 'ServerFailure: $message'
      '${statusCode != null ? ' (status: $statusCode)' : ''}'
      '${code != null ? ' (code: $code)' : ''}';
}

/// Failure representing local storage errors.
///
/// This includes secure storage read/write failures,
/// cache access errors, and other storage-related issues.
class StorageFailure extends Failure {
  const StorageFailure(super.message, [super.code]);

  @override
  String toString() => 'StorageFailure: $message${code != null ? ' (code: $code)' : ''}';
}
