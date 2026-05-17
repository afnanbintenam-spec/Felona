import 'package:felo_na/core/errors/error_handler.dart';
import 'package:felo_na/core/errors/exceptions.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorHandler', () {
    group('handleException', () {
      test('should transform NetworkException to NetworkFailure', () {
        const exception = NetworkException('Connection timeout', 'NET_001');
        
        final failure = ErrorHandler.handleException(exception);
        
        expect(failure, isA<NetworkFailure>());
        expect(failure.message, 'Connection timeout');
        expect(failure.code, 'NET_001');
      });

      test('should transform AuthenticationException to AuthFailure', () {
        const exception = AuthenticationException('Invalid token', 'AUTH_001');
        
        final failure = ErrorHandler.handleException(exception);
        
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'Invalid token');
        expect(failure.code, 'AUTH_001');
      });

      test('should transform ValidationException to ValidationFailure', () {
        const exception = ValidationException(
          'Validation failed',
          {'email': 'Invalid email'},
          'VAL_001',
        );
        
        final failure = ErrorHandler.handleException(exception);
        
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, 'Validation failed');
        expect(failure.code, 'VAL_001');
        expect((failure as ValidationFailure).fieldErrors, {'email': 'Invalid email'});
      });

      test('should transform AuthorizationException to AuthorizationFailure', () {
        const exception = AuthorizationException('Access denied', 'AUTHZ_001');
        
        final failure = ErrorHandler.handleException(exception);
        
        expect(failure, isA<AuthorizationFailure>());
        expect(failure.message, 'Access denied');
        expect(failure.code, 'AUTHZ_001');
      });

      test('should transform ServerException to ServerFailure', () {
        const exception = ServerException('Internal error', 500, 'SRV_001');
        
        final failure = ErrorHandler.handleException(exception);
        
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Internal error');
        expect(failure.code, 'SRV_001');
        expect((failure as ServerFailure).statusCode, 500);
      });

      test('should transform StorageException to StorageFailure', () {
        const exception = StorageException('Read failed', 'STR_001');
        
        final failure = ErrorHandler.handleException(exception);
        
        expect(failure, isA<StorageFailure>());
        expect(failure.message, 'Read failed');
        expect(failure.code, 'STR_001');
      });

      test('should transform generic AppException to ServerFailure', () {
        const exception = _TestAppException('Generic error', 'APP_001');
        
        final failure = ErrorHandler.handleException(exception);
        
        expect(failure, isA<ServerFailure>());
        expect(failure.message, 'Generic error');
        expect(failure.code, 'APP_001');
      });

      test('should handle unknown exception types', () {
        final exception = Exception('Unknown error');
        
        final failure = ErrorHandler.handleException(exception);
        
        expect(failure, isA<ServerFailure>());
        expect(failure.message, contains('An unexpected error occurred'));
        expect(failure.message, contains('Unknown error'));
      });

      test('should handle exceptions without code', () {
        const exception = NetworkException('Connection timeout');
        
        final failure = ErrorHandler.handleException(exception);
        
        expect(failure, isA<NetworkFailure>());
        expect(failure.message, 'Connection timeout');
        expect(failure.code, isNull);
      });

      test('should preserve field errors in ValidationException', () {
        const exception = ValidationException(
          'Multiple errors',
          {
            'email': 'Invalid email',
            'password': 'Too short',
          },
        );
        
        final failure = ErrorHandler.handleException(exception);
        
        expect(failure, isA<ValidationFailure>());
        final validationFailure = failure as ValidationFailure;
        expect(validationFailure.fieldErrors.length, 2);
        expect(validationFailure.fieldErrors['email'], 'Invalid email');
        expect(validationFailure.fieldErrors['password'], 'Too short');
      });

      test('should preserve status code in ServerException', () {
        const exception = ServerException('Not found', 404);
        
        final failure = ErrorHandler.handleException(exception);
        
        expect(failure, isA<ServerFailure>());
        expect((failure as ServerFailure).statusCode, 404);
      });
    });
  });
}

// Test helper class
class _TestAppException extends AppException {
  const _TestAppException(super.message, [super.code]);
}
