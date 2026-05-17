import 'exceptions.dart';
import 'failures.dart';

/// Utility class for transforming exceptions into failures.
///
/// This class provides a centralized way to convert data layer exceptions
/// into domain layer failures, ensuring consistent error handling across
/// all repositories.
class ErrorHandler {
  /// Transforms an exception into a corresponding failure.
  ///
  /// This method maps exception types to their corresponding failure types,
  /// preserving error messages and codes.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final result = await apiCall();
  ///   return Right(result);
  /// } catch (e) {
  ///   return Left(ErrorHandler.handleException(e));
  /// }
  /// ```
  static Failure handleException(Object exception) {
    if (exception is NetworkException) {
      return NetworkFailure(exception.message, exception.code);
    } else if (exception is AuthenticationException) {
      return AuthFailure(exception.message, exception.code);
    } else if (exception is ValidationException) {
      return ValidationFailure(
        exception.message,
        exception.fieldErrors,
        exception.code,
      );
    } else if (exception is AuthorizationException) {
      return AuthorizationFailure(exception.message, exception.code);
    } else if (exception is ServerException) {
      return ServerFailure(
        exception.message,
        exception.statusCode,
        exception.code,
      );
    } else if (exception is StorageException) {
      return StorageFailure(exception.message, exception.code);
    } else if (exception is AppException) {
      // Generic AppException fallback
      return ServerFailure(exception.message, null, exception.code);
    } else {
      // Unknown exception type
      return ServerFailure(
        'An unexpected error occurred: ${exception.toString()}',
      );
    }
  }
}
