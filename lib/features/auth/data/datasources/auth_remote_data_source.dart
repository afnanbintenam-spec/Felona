import 'dart:io';

import 'package:dio/dio.dart';
import 'package:felo_na/core/errors/exceptions.dart';
import 'package:felo_na/core/network/api_client.dart';
import 'package:felo_na/features/auth/data/models/user_model.dart';

/// Holds the authentication response containing both user data and JWT token.
class AuthResponse {
  final UserModel user;
  final String token;

  const AuthResponse({required this.user, required this.token});
}

/// Abstract interface for the authentication remote data source.
///
/// Defines the contract for communicating with the backend API
/// for all authentication-related operations.
abstract class AuthRemoteDataSource {
  /// Registers a new user with the given credentials and role.
  ///
  /// Sends a POST request to the registration endpoint.
  /// Returns a [UserModel] on success.
  /// Throws [ServerException] if the server returns an error.
  /// Throws [ValidationException] if input validation fails (e.g., email already exists).
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  });

  /// Registers a new user and returns both user data and JWT token.
  ///
  /// Returns an [AuthResponse] containing the user and token.
  /// Throws [ServerException] if the server returns an error.
  /// Throws [ValidationException] if input validation fails.
  Future<AuthResponse> registerWithToken({
    required String fullName,
    required String email,
    required String password,
    required String role,
  });

  /// Authenticates a user with email and password.
  ///
  /// Sends a POST request to the login endpoint.
  /// Returns a [UserModel] on success.
  /// Throws [AuthenticationException] if credentials are invalid.
  /// Throws [ServerException] for other server errors.
  Future<UserModel> login({
    required String email,
    required String password,
  });

  /// Authenticates a user and returns both user data and JWT token.
  ///
  /// Returns an [AuthResponse] containing the user and token.
  /// Throws [AuthenticationException] if credentials are invalid.
  /// Throws [ServerException] for other server errors.
  Future<AuthResponse> loginWithToken({
    required String email,
    required String password,
  });

  /// Updates the authenticated user's profile information.
  ///
  /// Sends a PUT request to the profile update endpoint.
  /// Returns the updated [UserModel].
  /// Throws [AuthenticationException] if the user is not authenticated.
  /// Throws [ValidationException] if the update data is invalid.
  /// Throws [ServerException] for other server errors.
  Future<UserModel> updateProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
  });

  /// Uploads a profile picture for the authenticated user.
  ///
  /// Sends a multipart POST request with the image file.
  /// Returns the URL of the uploaded profile picture.
  /// Throws [ValidationException] if the file exceeds 5MB or is not JPEG/PNG.
  /// Throws [ServerException] for other server errors.
  Future<String> uploadProfilePicture({
    required String userId,
    required File imageFile,
  });

  /// Retrieves the currently authenticated user's profile.
  ///
  /// Sends a GET request to the current user endpoint.
  /// Returns a [UserModel] on success.
  /// Throws [AuthenticationException] if the token is invalid or expired.
  /// Throws [ServerException] for other server errors.
  Future<UserModel> getCurrentUser();
}

/// Implementation of [AuthRemoteDataSource] using Dio HTTP client.
///
/// Communicates with the backend REST API for authentication operations.
/// All HTTP errors are transformed into typed exceptions by the [ApiClient]'s
/// error interceptor, so this class re-throws them as-is for the repository
/// layer to handle.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  /// API endpoint paths for authentication operations.
  static const String _registerPath = '/auth/register';
  static const String _loginPath = '/auth/login';
  static const String _profilePath = '/auth/profile';
  static const String _currentUserPath = '/auth/me';

  AuthRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _apiClient.post(
        _registerPath,
        data: {
          'full_name': fullName,
          'email': email,
          'password': password,
          'role': role,
        },
      );

      return UserModel.fromJson(
        response.data['user'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<AuthResponse> registerWithToken({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _apiClient.post(
        _registerPath,
        data: {
          'full_name': fullName,
          'email': email,
          'password': password,
          'role': role,
        },
      );

      final user = UserModel.fromJson(
        response.data['user'] as Map<String, dynamic>,
      );
      final token = response.data['token'] as String;

      return AuthResponse(user: user, token: token);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        _loginPath,
        data: {
          'email': email,
          'password': password,
        },
      );

      return UserModel.fromJson(
        response.data['user'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<AuthResponse> loginWithToken({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        _loginPath,
        data: {
          'email': email,
          'password': password,
        },
      );

      final user = UserModel.fromJson(
        response.data['user'] as Map<String, dynamic>,
      );
      final token = response.data['token'] as String;

      return AuthResponse(user: user, token: token);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (phoneNumber != null) data['phone_number'] = phoneNumber;

      final response = await _apiClient.put(
        '$_profilePath/$userId',
        data: data,
      );

      return UserModel.fromJson(
        response.data['user'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<String> uploadProfilePicture({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final fileName = imageFile.path.split(Platform.pathSeparator).last;
      final formData = FormData.fromMap({
        'profile_picture': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _apiClient.uploadMultipart(
        '$_profilePath/$userId/picture',
        formData,
      );

      return response.data['profile_picture_url'] as String;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiClient.get(_currentUserPath);

      return UserModel.fromJson(
        response.data['user'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Extracts the typed exception from a [DioException].
  ///
  /// The [ErrorInterceptor] in [ApiClient] transforms HTTP errors into
  /// domain-specific exceptions and attaches them to the [DioException.error]
  /// field. This method extracts that exception or creates a fallback
  /// [ServerException] if the error is not already typed.
  AppException _handleDioError(DioException e) {
    if (e.error is AppException) {
      return e.error as AppException;
    }
    return ServerException(
      e.message ?? 'An unexpected error occurred.',
      e.response?.statusCode,
    );
  }
}
