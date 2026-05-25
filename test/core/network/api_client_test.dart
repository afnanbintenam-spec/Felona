import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:felo_na/core/network/api_client.dart';
import 'package:felo_na/core/network/auth_interceptor.dart';
import 'package:felo_na/core/errors/exceptions.dart';

void main() {
  group('ApiClient', () {
    late FlutterSecureStorage secureStorage;
    late ApiClient apiClient;

    setUp(() {
      // Use the actual FlutterSecureStorage for testing
      // In a real test environment, this would use a mock or test implementation
      secureStorage = const FlutterSecureStorage();
      apiClient = ApiClient(secureStorage: secureStorage);
    });

    test('should create ApiClient instance successfully', () {
      expect(apiClient, isNotNull);
    });

    test('should configure Dio with correct base URL', () {
      expect(ApiClient.baseUrl, contains(':3000'));
    });

    test('should have correct timeout duration', () {
      expect(ApiClient.timeout, const Duration(seconds: 30));
    });
  });

  group('ErrorInterceptor - Error Transformation', () {
    late ErrorInterceptor errorInterceptor;

    setUp(() {
      errorInterceptor = ErrorInterceptor();
    });

    test('should transform connection timeout to NetworkException', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      DioException? capturedError;
      final handler = _TestErrorHandler(
        onReject: (err) => capturedError = err,
      );

      errorInterceptor.onError(error, handler);

      expect(capturedError, isNotNull);
      expect(capturedError!.error, isA<NetworkException>());
      expect((capturedError!.error as NetworkException).message, contains('Connection timeout'));
      expect((capturedError!.error as NetworkException).code, 'TIMEOUT');
    });

    test('should transform send timeout to NetworkException', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.sendTimeout,
      );

      DioException? capturedError;
      final handler = _TestErrorHandler(
        onReject: (err) => capturedError = err,
      );

      errorInterceptor.onError(error, handler);

      expect(capturedError!.error, isA<NetworkException>());
      expect((capturedError!.error as NetworkException).code, 'TIMEOUT');
    });

    test('should transform connection error to NetworkException', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );

      DioException? capturedError;
      final handler = _TestErrorHandler(
        onReject: (err) => capturedError = err,
      );

      errorInterceptor.onError(error, handler);

      expect(capturedError!.error, isA<NetworkException>());
      expect((capturedError!.error as NetworkException).message, contains('No internet connection'));
      expect((capturedError!.error as NetworkException).code, 'NO_CONNECTION');
    });

    test('should transform 400 response to ValidationException with field errors', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 400,
          data: {
            'message': 'Validation failed',
            'errors': {
              'email': 'Invalid email format',
              'password': 'Password too short',
            },
          },
        ),
      );

      DioException? capturedError;
      final handler = _TestErrorHandler(
        onReject: (err) => capturedError = err,
      );

      errorInterceptor.onError(error, handler);

      expect(capturedError!.error, isA<ValidationException>());
      final validationError = capturedError!.error as ValidationException;
      expect(validationError.message, 'Validation failed');
      expect(validationError.fieldErrors['email'], 'Invalid email format');
      expect(validationError.fieldErrors['password'], 'Password too short');
      expect(validationError.code, 'BAD_REQUEST');
    });

    test('should transform 401 response to AuthenticationException', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
          data: {'message': 'Invalid credentials'},
        ),
      );

      DioException? capturedError;
      final handler = _TestErrorHandler(
        onReject: (err) => capturedError = err,
      );

      errorInterceptor.onError(error, handler);

      expect(capturedError!.error, isA<AuthenticationException>());
      expect((capturedError!.error as AuthenticationException).message, 'Invalid credentials');
      expect((capturedError!.error as AuthenticationException).code, 'UNAUTHORIZED');
    });

    test('should transform 403 response to AuthorizationException', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 403,
          data: {'message': 'Access denied'},
        ),
      );

      DioException? capturedError;
      final handler = _TestErrorHandler(
        onReject: (err) => capturedError = err,
      );

      errorInterceptor.onError(error, handler);

      expect(capturedError!.error, isA<AuthorizationException>());
      expect((capturedError!.error as AuthorizationException).message, 'Access denied');
      expect((capturedError!.error as AuthorizationException).code, 'FORBIDDEN');
    });

    test('should transform 404 response to ServerException', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 404,
          data: {'message': 'Resource not found'},
        ),
      );

      DioException? capturedError;
      final handler = _TestErrorHandler(
        onReject: (err) => capturedError = err,
      );

      errorInterceptor.onError(error, handler);

      expect(capturedError!.error, isA<ServerException>());
      expect((capturedError!.error as ServerException).message, 'Resource not found');
      expect((capturedError!.error as ServerException).statusCode, 404);
      expect((capturedError!.error as ServerException).code, 'NOT_FOUND');
    });

    test('should transform 409 response to ValidationException', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 409,
          data: {'message': 'Email already exists'},
        ),
      );

      DioException? capturedError;
      final handler = _TestErrorHandler(
        onReject: (err) => capturedError = err,
      );

      errorInterceptor.onError(error, handler);

      expect(capturedError!.error, isA<ValidationException>());
      expect((capturedError!.error as ValidationException).message, 'Email already exists');
      expect((capturedError!.error as ValidationException).code, 'CONFLICT');
    });

    test('should transform 422 response to ValidationException', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 422,
          data: {'message': 'Unprocessable entity'},
        ),
      );

      DioException? capturedError;
      final handler = _TestErrorHandler(
        onReject: (err) => capturedError = err,
      );

      errorInterceptor.onError(error, handler);

      expect(capturedError!.error, isA<ValidationException>());
      expect((capturedError!.error as ValidationException).code, 'VALIDATION_ERROR');
    });

    test('should transform 429 response to ServerException', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 429,
          data: {'message': 'Too many requests'},
        ),
      );

      DioException? capturedError;
      final handler = _TestErrorHandler(
        onReject: (err) => capturedError = err,
      );

      errorInterceptor.onError(error, handler);

      expect(capturedError!.error, isA<ServerException>());
      expect((capturedError!.error as ServerException).statusCode, 429);
      expect((capturedError!.error as ServerException).code, 'RATE_LIMIT');
    });

    test('should transform 500 response to ServerException', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
          data: {'message': 'Internal server error'},
        ),
      );

      DioException? capturedError;
      final handler = _TestErrorHandler(
        onReject: (err) => capturedError = err,
      );

      errorInterceptor.onError(error, handler);

      expect(capturedError!.error, isA<ServerException>());
      expect((capturedError!.error as ServerException).message, 'Internal server error');
      expect((capturedError!.error as ServerException).statusCode, 500);
      expect((capturedError!.error as ServerException).code, 'SERVER_ERROR');
    });

    test('should parse field errors in array format', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 400,
          data: {
            'message': 'Validation failed',
            'errors': [
              {'field': 'email', 'message': 'Invalid email'},
              {'field': 'password', 'message': 'Too short'},
            ],
          },
        ),
      );

      DioException? capturedError;
      final handler = _TestErrorHandler(
        onReject: (err) => capturedError = err,
      );

      errorInterceptor.onError(error, handler);

      expect(capturedError!.error, isA<ValidationException>());
      final validationError = capturedError!.error as ValidationException;
      expect(validationError.fieldErrors['email'], 'Invalid email');
      expect(validationError.fieldErrors['password'], 'Too short');
    });

    test('should handle response with no data', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
        ),
      );

      DioException? capturedError;
      final handler = _TestErrorHandler(
        onReject: (err) => capturedError = err,
      );

      errorInterceptor.onError(error, handler);

      expect(capturedError!.error, isA<ServerException>());
    });

    test('should handle response with string data', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 400,
          data: 'Bad request error',
        ),
      );

      DioException? capturedError;
      final handler = _TestErrorHandler(
        onReject: (err) => capturedError = err,
      );

      errorInterceptor.onError(error, handler);

      expect(capturedError!.error, isA<ValidationException>());
      expect((capturedError!.error as ValidationException).message, 'Bad request error');
    });

    test('should transform cancel error to NetworkException', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.cancel,
      );

      DioException? capturedError;
      final handler = _TestErrorHandler(
        onReject: (err) => capturedError = err,
      );

      errorInterceptor.onError(error, handler);

      expect(capturedError!.error, isA<NetworkException>());
      expect((capturedError!.error as NetworkException).message, 'Request cancelled.');
      expect((capturedError!.error as NetworkException).code, 'CANCELLED');
    });

    test('should transform bad certificate error to NetworkException', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badCertificate,
      );

      DioException? capturedError;
      final handler = _TestErrorHandler(
        onReject: (err) => capturedError = err,
      );

      errorInterceptor.onError(error, handler);

      expect(capturedError!.error, isA<NetworkException>());
      expect((capturedError!.error as NetworkException).code, 'BAD_CERTIFICATE');
    });

    test('should handle null response', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: null,
      );

      DioException? capturedError;
      final handler = _TestErrorHandler(
        onReject: (err) => capturedError = err,
      );

      errorInterceptor.onError(error, handler);

      expect(capturedError!.error, isA<ServerException>());
      expect((capturedError!.error as ServerException).message, 'No response from server.');
    });
  });

  group('AuthRefreshInterceptor', () {
    test('should have correct token key constants', () {
      expect(TokenKeys.accessToken, 'auth_token');
      expect(TokenKeys.refreshToken, 'refresh_token');
    });
  });

  group('LoggingInterceptor', () {
    late LoggingInterceptor loggingInterceptor;

    setUp(() {
      loggingInterceptor = LoggingInterceptor();
    });

    test('should create LoggingInterceptor instance', () {
      expect(loggingInterceptor, isNotNull);
    });
  });
}

// Test helper class for ErrorInterceptorHandler
class _TestErrorHandler extends ErrorInterceptorHandler {
  final void Function(DioException)? onReject;
  final void Function(DioException)? onNext;
  final void Function(Response)? onResolve;

  _TestErrorHandler({
    this.onReject,
    this.onNext,
    this.onResolve,
  });

  @override
  void reject(DioException err, [bool newError = false]) {
    onReject?.call(err);
  }

  @override
  void next(DioException err) {
    onNext?.call(err);
  }

  @override
  void resolve(Response response) {
    onResolve?.call(response);
  }
}
