import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../errors/exceptions.dart';
import 'auth_interceptor.dart';

/// Centralized HTTP client for making API requests.
///
/// Provides a configured Dio instance with interceptors for:
/// - Authentication (JWT token injection + auto refresh)
/// - Request/response logging
/// - Error transformation
class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  /// Callback triggered when token refresh fails and user must re-login.
  void Function()? onForceLogout;

  /// Base URL for the API.
  /// - Android emulator: 10.0.2.2 maps to host machine's localhost
  /// - iOS simulator / Web / Desktop: localhost works directly
  /// - Physical device: uses machine's LAN IP
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://192.168.0.234:3000';
    return 'http://localhost:3000';
  }

  /// Default timeout duration for requests
  static const Duration timeout = Duration(seconds: 30);

  ApiClient({
    required FlutterSecureStorage secureStorage,
    Dio? dio,
    this.onForceLogout,
  })  : _secureStorage = secureStorage,
        _dio = dio ?? Dio() {
    _configureDio();
  }

  /// Configures Dio with base options and interceptors
  void _configureDio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptors in order: Auth (with refresh) -> Logging -> Error
    _dio.interceptors.addAll([
      AuthRefreshInterceptor(
        dio: _dio,
        storage: _secureStorage,
        baseUrl: baseUrl,
        onForceLogout: () => onForceLogout?.call(),
      ),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  /// Performs a GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Performs a POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Performs a PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Performs a DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Performs a PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Uploads multipart form data (e.g., file uploads)
  Future<Response> uploadMultipart(
    String path,
    FormData formData, {
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    return await _dio.post(
      path,
      data: formData,
      options: options,
      onSendProgress: onSendProgress,
    );
  }
}

/// Interceptor that logs HTTP requests and responses for debugging.
///
/// Logs request details (method, URL, headers, body) and response details
/// (status code, headers, body) to the console.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('┌─────────────────────────────────────────────────────────────');
    print('│ REQUEST: ${options.method} ${options.uri}');
    print('│ Headers: ${options.headers}');
    if (options.data != null) {
      print('│ Body: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      print('│ Query Parameters: ${options.queryParameters}');
    }
    print('└─────────────────────────────────────────────────────────────');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('┌─────────────────────────────────────────────────────────────');
    print('│ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    print('│ Headers: ${response.headers}');
    print('│ Body: ${response.data}');
    print('└─────────────────────────────────────────────────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('┌─────────────────────────────────────────────────────────────');
    print('│ ERROR: ${err.requestOptions.method} ${err.requestOptions.uri}');
    print('│ Type: ${err.type}');
    print('│ Message: ${err.message}');
    if (err.response != null) {
      print('│ Status Code: ${err.response?.statusCode}');
      print('│ Response: ${err.response?.data}');
    }
    print('└─────────────────────────────────────────────────────────────');
    handler.next(err);
  }
}

/// Interceptor that transforms HTTP errors into domain-specific exceptions.
///
/// Converts Dio exceptions and HTTP error responses into application-specific
/// exception types (NetworkException, AuthenticationException, etc.) that can
/// be handled consistently throughout the app.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _transformError(err);

    // Create a new DioException with the transformed exception as the error
    final transformedError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: exception,
      message: exception.message,
    );

    handler.reject(transformedError);
  }

  /// Transforms a DioException into an application-specific exception
  AppException _transformError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          'Connection timeout. Please check your internet connection.',
          'TIMEOUT',
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(err.response);

      case DioExceptionType.cancel:
        return const NetworkException('Request cancelled.', 'CANCELLED');

      case DioExceptionType.connectionError:
        return const NetworkException(
          'No internet connection. Please check your network.',
          'NO_CONNECTION',
        );

      case DioExceptionType.badCertificate:
        return const NetworkException(
          'Security certificate error.',
          'BAD_CERTIFICATE',
        );

      case DioExceptionType.unknown:
        return NetworkException(
          'Network error occurred: ${err.message ?? "Unknown error"}',
          'UNKNOWN',
        );
    }
  }

  /// Handles HTTP response errors based on status code
  AppException _handleResponseError(Response? response) {
    if (response == null) {
      return const ServerException('No response from server.', null, 'NO_RESPONSE');
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    // Extract error message from response
    String message = 'An error occurred.';
    String? code;

    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['error'] ?? message;
      code = data['code'];
    } else if (data is String) {
      message = data;
    }

    switch (statusCode) {
      case 400:
        // Bad Request - Validation Error
        return ValidationException(
          message.isEmpty ? 'Invalid request.' : message,
          _parseFieldErrors(data),
          code ?? 'BAD_REQUEST',
        );

      case 401:
        // Unauthorized - Authentication Error
        return AuthenticationException(
          message.isEmpty ? 'Authentication failed. Please log in again.' : message,
          code ?? 'UNAUTHORIZED',
        );

      case 403:
        // Forbidden - Authorization Error
        return AuthorizationException(
          message.isEmpty ? 'Access denied. You do not have permission.' : message,
          code ?? 'FORBIDDEN',
        );

      case 404:
        // Not Found
        return ServerException(
          message.isEmpty ? 'Resource not found.' : message,
          statusCode,
          code ?? 'NOT_FOUND',
        );

      case 409:
        // Conflict - Often used for duplicate entries
        return ValidationException(
          message.isEmpty ? 'Conflict occurred.' : message,
          _parseFieldErrors(data),
          code ?? 'CONFLICT',
        );

      case 422:
        // Unprocessable Entity - Validation Error
        return ValidationException(
          message.isEmpty ? 'Validation failed.' : message,
          _parseFieldErrors(data),
          code ?? 'VALIDATION_ERROR',
        );

      case 429:
        // Too Many Requests
        return ServerException(
          message.isEmpty ? 'Too many requests. Please try again later.' : message,
          statusCode,
          code ?? 'RATE_LIMIT',
        );

      case 500:
      case 502:
      case 503:
      case 504:
        // Server Errors
        return ServerException(
          message.isEmpty ? 'Server error. Please try again later.' : message,
          statusCode,
          code ?? 'SERVER_ERROR',
        );

      default:
        return ServerException(
          message.isEmpty ? 'Unexpected error occurred.' : message,
          statusCode,
          code ?? 'UNKNOWN_ERROR',
        );
    }
  }

  /// Parses field-level validation errors from response data
  Map<String, String> _parseFieldErrors(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return {};
    }

    // Try different common field error formats
    if (data.containsKey('errors')) {
      final errors = data['errors'];

      // Format 1: { "errors": { "email": "Invalid email", "password": "Too short" } }
      if (errors is Map<String, dynamic>) {
        return errors.map((key, value) => MapEntry(key, value.toString()));
      }

      // Format 2: { "errors": [ { "field": "email", "message": "Invalid" } ] }
      if (errors is List) {
        final fieldErrors = <String, String>{};
        for (final error in errors) {
          if (error is Map<String, dynamic>) {
            final field = error['field'] ?? error['param'] ?? error['property'];
            final message = error['message'] ?? error['msg'] ?? 'Invalid value';
            if (field != null) {
              fieldErrors[field.toString()] = message.toString();
            }
          }
        }
        return fieldErrors;
      }
    }

    // Format 3: { "field_errors": { ... } }
    if (data.containsKey('field_errors') && data['field_errors'] is Map) {
      return Map<String, String>.from(data['field_errors']);
    }

    // Format 4: { "validation_errors": { ... } }
    if (data.containsKey('validation_errors') && data['validation_errors'] is Map) {
      return Map<String, String>.from(data['validation_errors']);
    }

    return {};
  }
}
