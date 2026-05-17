import 'package:felo_na/core/errors/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppException', () {
    test('should create exception with message only', () {
      const exception = NetworkException('Network error');
      
      expect(exception.message, 'Network error');
      expect(exception.code, isNull);
    });

    test('should create exception with message and code', () {
      const exception = NetworkException('Network error', 'NET_001');
      
      expect(exception.message, 'Network error');
      expect(exception.code, 'NET_001');
    });

    test('should have proper toString representation', () {
      const exception = NetworkException('Network error', 'NET_001');
      
      expect(
        exception.toString(),
        'NetworkException: Network error (code: NET_001)',
      );
    });
  });

  group('NetworkException', () {
    test('should extend AppException', () {
      const exception = NetworkException('Connection timeout');
      
      expect(exception, isA<AppException>());
      expect(exception.message, 'Connection timeout');
    });

    test('should have proper toString', () {
      const exception = NetworkException('No internet connection', 'NET_002');
      
      expect(
        exception.toString(),
        'NetworkException: No internet connection (code: NET_002)',
      );
    });
  });

  group('AuthenticationException', () {
    test('should extend AppException', () {
      const exception = AuthenticationException('Invalid credentials');
      
      expect(exception, isA<AppException>());
      expect(exception.message, 'Invalid credentials');
    });

    test('should have proper toString', () {
      const exception = AuthenticationException('Token expired', 'AUTH_001');
      
      expect(
        exception.toString(),
        'AuthenticationException: Token expired (code: AUTH_001)',
      );
    });
  });

  group('ValidationException', () {
    test('should extend AppException', () {
      const exception = ValidationException(
        'Validation failed',
        {'email': 'Invalid email format'},
      );
      
      expect(exception, isA<AppException>());
      expect(exception.message, 'Validation failed');
      expect(exception.fieldErrors, {'email': 'Invalid email format'});
    });

    test('should handle multiple field errors', () {
      const exception = ValidationException(
        'Multiple validation errors',
        {
          'email': 'Invalid email format',
          'password': 'Password too short',
        },
      );
      
      expect(exception.fieldErrors.length, 2);
      expect(exception.fieldErrors['email'], 'Invalid email format');
      expect(exception.fieldErrors['password'], 'Password too short');
    });

    test('should have proper toString with field errors', () {
      const exception = ValidationException(
        'Validation failed',
        {'email': 'Invalid email'},
        'VAL_001',
      );
      
      final str = exception.toString();
      expect(str, contains('ValidationException: Validation failed'));
      expect(str, contains('(code: VAL_001)'));
      expect(str, contains('email: Invalid email'));
    });

    test('should handle empty field errors', () {
      const exception = ValidationException(
        'Validation failed',
        {},
      );
      
      expect(exception.fieldErrors, isEmpty);
      expect(
        exception.toString(),
        'ValidationException: Validation failed',
      );
    });
  });

  group('AuthorizationException', () {
    test('should extend AppException', () {
      const exception = AuthorizationException('Access denied');
      
      expect(exception, isA<AppException>());
      expect(exception.message, 'Access denied');
    });

    test('should have proper toString', () {
      const exception = AuthorizationException(
        'Insufficient permissions',
        'AUTHZ_001',
      );
      
      expect(
        exception.toString(),
        'AuthorizationException: Insufficient permissions (code: AUTHZ_001)',
      );
    });
  });

  group('ServerException', () {
    test('should extend AppException', () {
      const exception = ServerException('Internal server error');
      
      expect(exception, isA<AppException>());
      expect(exception.message, 'Internal server error');
    });

    test('should store status code', () {
      const exception = ServerException('Server error', 500);
      
      expect(exception.statusCode, 500);
      expect(exception.message, 'Server error');
    });

    test('should have proper toString with status code', () {
      const exception = ServerException('Server error', 500, 'SRV_001');
      
      expect(
        exception.toString(),
        'ServerException: Server error (status: 500) (code: SRV_001)',
      );
    });

    test('should handle null status code', () {
      const exception = ServerException('Server error', null, 'SRV_002');
      
      expect(exception.statusCode, isNull);
      expect(
        exception.toString(),
        'ServerException: Server error (code: SRV_002)',
      );
    });
  });

  group('StorageException', () {
    test('should extend AppException', () {
      const exception = StorageException('Storage read failed');
      
      expect(exception, isA<AppException>());
      expect(exception.message, 'Storage read failed');
    });

    test('should have proper toString', () {
      const exception = StorageException('Storage write failed', 'STR_001');
      
      expect(
        exception.toString(),
        'StorageException: Storage write failed (code: STR_001)',
      );
    });
  });
}
