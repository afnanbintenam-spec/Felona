import 'package:felo_na/core/errors/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure', () {
    test('should support value equality with same message and code', () {
      const failure1 = NetworkFailure('Network error', 'NET_001');
      const failure2 = NetworkFailure('Network error', 'NET_001');
      
      expect(failure1, equals(failure2));
    });

    test('should not be equal with different messages', () {
      const failure1 = NetworkFailure('Network error 1');
      const failure2 = NetworkFailure('Network error 2');
      
      expect(failure1, isNot(equals(failure2)));
    });

    test('should not be equal with different codes', () {
      const failure1 = NetworkFailure('Network error', 'NET_001');
      const failure2 = NetworkFailure('Network error', 'NET_002');
      
      expect(failure1, isNot(equals(failure2)));
    });

    test('should have proper toString representation', () {
      const failure = NetworkFailure('Network error', 'NET_001');
      
      expect(
        failure.toString(),
        'NetworkFailure: Network error (code: NET_001)',
      );
    });
  });

  group('NetworkFailure', () {
    test('should extend Failure', () {
      const failure = NetworkFailure('Connection timeout');
      
      expect(failure, isA<Failure>());
      expect(failure.message, 'Connection timeout');
    });

    test('should create failure with message only', () {
      const failure = NetworkFailure('No internet connection');
      
      expect(failure.message, 'No internet connection');
      expect(failure.code, isNull);
    });

    test('should create failure with message and code', () {
      const failure = NetworkFailure('Connection timeout', 'NET_001');
      
      expect(failure.message, 'Connection timeout');
      expect(failure.code, 'NET_001');
    });

    test('should have proper toString', () {
      const failure = NetworkFailure('Network error', 'NET_002');
      
      expect(
        failure.toString(),
        'NetworkFailure: Network error (code: NET_002)',
      );
    });
  });

  group('AuthFailure', () {
    test('should extend Failure', () {
      const failure = AuthFailure('Invalid credentials');
      
      expect(failure, isA<Failure>());
      expect(failure.message, 'Invalid credentials');
    });

    test('should have proper toString', () {
      const failure = AuthFailure('Token expired', 'AUTH_001');
      
      expect(
        failure.toString(),
        'AuthFailure: Token expired (code: AUTH_001)',
      );
    });
  });

  group('ValidationFailure', () {
    test('should extend Failure', () {
      const failure = ValidationFailure(
        'Validation failed',
        {'email': 'Invalid email format'},
      );
      
      expect(failure, isA<Failure>());
      expect(failure.message, 'Validation failed');
      expect(failure.fieldErrors, {'email': 'Invalid email format'});
    });

    test('should handle multiple field errors', () {
      const failure = ValidationFailure(
        'Multiple validation errors',
        {
          'email': 'Invalid email format',
          'password': 'Password too short',
        },
      );
      
      expect(failure.fieldErrors.length, 2);
      expect(failure.fieldErrors['email'], 'Invalid email format');
      expect(failure.fieldErrors['password'], 'Password too short');
    });

    test('should support equality with field errors', () {
      const failure1 = ValidationFailure(
        'Validation failed',
        {'email': 'Invalid email'},
        'VAL_001',
      );
      const failure2 = ValidationFailure(
        'Validation failed',
        {'email': 'Invalid email'},
        'VAL_001',
      );
      
      expect(failure1, equals(failure2));
    });

    test('should not be equal with different field errors', () {
      const failure1 = ValidationFailure(
        'Validation failed',
        {'email': 'Invalid email'},
      );
      const failure2 = ValidationFailure(
        'Validation failed',
        {'password': 'Too short'},
      );
      
      expect(failure1, isNot(equals(failure2)));
    });

    test('should have proper toString with field errors', () {
      const failure = ValidationFailure(
        'Validation failed',
        {'email': 'Invalid email'},
        'VAL_001',
      );
      
      final str = failure.toString();
      expect(str, contains('ValidationFailure: Validation failed'));
      expect(str, contains('(code: VAL_001)'));
      expect(str, contains('email: Invalid email'));
    });

    test('should handle empty field errors', () {
      const failure = ValidationFailure(
        'Validation failed',
        {},
      );
      
      expect(failure.fieldErrors, isEmpty);
      expect(
        failure.toString(),
        'ValidationFailure: Validation failed',
      );
    });
  });

  group('AuthorizationFailure', () {
    test('should extend Failure', () {
      const failure = AuthorizationFailure('Access denied');
      
      expect(failure, isA<Failure>());
      expect(failure.message, 'Access denied');
    });

    test('should have proper toString', () {
      const failure = AuthorizationFailure(
        'Insufficient permissions',
        'AUTHZ_001',
      );
      
      expect(
        failure.toString(),
        'AuthorizationFailure: Insufficient permissions (code: AUTHZ_001)',
      );
    });
  });

  group('ServerFailure', () {
    test('should extend Failure', () {
      const failure = ServerFailure('Internal server error');
      
      expect(failure, isA<Failure>());
      expect(failure.message, 'Internal server error');
    });

    test('should store status code', () {
      const failure = ServerFailure('Server error', 500);
      
      expect(failure.statusCode, 500);
      expect(failure.message, 'Server error');
    });

    test('should support equality with status code', () {
      const failure1 = ServerFailure('Server error', 500, 'SRV_001');
      const failure2 = ServerFailure('Server error', 500, 'SRV_001');
      
      expect(failure1, equals(failure2));
    });

    test('should not be equal with different status codes', () {
      const failure1 = ServerFailure('Server error', 500);
      const failure2 = ServerFailure('Server error', 502);
      
      expect(failure1, isNot(equals(failure2)));
    });

    test('should have proper toString with status code', () {
      const failure = ServerFailure('Server error', 500, 'SRV_001');
      
      expect(
        failure.toString(),
        'ServerFailure: Server error (status: 500) (code: SRV_001)',
      );
    });

    test('should handle null status code', () {
      const failure = ServerFailure('Server error', null, 'SRV_002');
      
      expect(failure.statusCode, isNull);
      expect(
        failure.toString(),
        'ServerFailure: Server error (code: SRV_002)',
      );
    });
  });

  group('StorageFailure', () {
    test('should extend Failure', () {
      const failure = StorageFailure('Storage read failed');
      
      expect(failure, isA<Failure>());
      expect(failure.message, 'Storage read failed');
    });

    test('should have proper toString', () {
      const failure = StorageFailure('Storage write failed', 'STR_001');
      
      expect(
        failure.toString(),
        'StorageFailure: Storage write failed (code: STR_001)',
      );
    });
  });
}
