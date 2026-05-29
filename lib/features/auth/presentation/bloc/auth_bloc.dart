import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/core/network/api_client.dart';
import 'package:felo_na/core/network/auth_interceptor.dart';
import 'package:felo_na/core/network/web_storage.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_event.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_state.dart';
import 'package:felo_na/features/auth/data/models/user_model.dart';

/// AuthBloc — backend-wired with OTP-required registration & token refresh
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Dio _dio;
  final AppStorage _storage;

  AuthBloc({Dio? dio, AppStorage? storage})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: ApiClient.baseUrl,
              headers: {'Content-Type': 'application/json'},
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              validateStatus: (s) => s != null && s < 500,
            )),
        _storage = storage ?? AppStorage(),
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheck);
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
    on<UpdateProfileRequested>(_onUpdateProfile);
    on<UploadProfilePictureRequested>(_onUploadPicture);
    on<VerificationCompleted>(_onVerificationCompleted);
  }

  Future<void> _onAuthCheck(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final token = await _storage.read(key: TokenKeys.accessToken);
      if (token == null || token.isEmpty) {
        emit(const Unauthenticated());
        return;
      }

      final response = await _dio.get('/auth/me',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData = json.decode(response.data as String) as Map<String, dynamic>;
      } else {
        responseData = response.data as Map<String, dynamic>;
      }

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(responseData['user'] as Map<String, dynamic>);
        emit(Authenticated(user: user));
      } else if (response.statusCode == 401) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          final newToken = await _storage.read(key: TokenKeys.accessToken);
          final retryResponse = await _dio.get('/auth/me',
              options: Options(headers: {'Authorization': 'Bearer $newToken'}));
          
          Map<String, dynamic> retryData;
          if (retryResponse.data is String) {
            retryData = json.decode(retryResponse.data as String) as Map<String, dynamic>;
          } else {
            retryData = retryResponse.data as Map<String, dynamic>;
          }
          
          if (retryResponse.statusCode == 200) {
            final user = UserModel.fromJson(retryData['user'] as Map<String, dynamic>);
            emit(Authenticated(user: user));
          } else {
            await _clearTokens();
            emit(const Unauthenticated());
          }
        } else {
          await _clearTokens();
          emit(const Unauthenticated());
        }
      } else {
        await _clearTokens();
        emit(const Unauthenticated());
      }
    } catch (_) {
      await _clearTokens();
      emit(const Unauthenticated());
    }
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      debugPrint('[AuthBloc] Attempting login to ${ApiClient.baseUrl}/auth/login');
      
      final response = await _dio.post('/auth/login', data: {
        'email': event.email,
        'password': event.password,
      });

      debugPrint('[AuthBloc] Login response status: ${response.statusCode}');
      debugPrint('[AuthBloc] Login response data type: ${response.data.runtimeType}');

      // Parse response data — on web it might come as String
      Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData = json.decode(response.data as String) as Map<String, dynamic>;
      } else {
        responseData = response.data as Map<String, dynamic>;
      }

      if (response.statusCode == 200) {
        final accessToken = responseData['token']?.toString() ??
            responseData['accessToken']?.toString() ??
            responseData['access_token']?.toString();
        
        if (accessToken == null || accessToken.isEmpty) {
          emit(const AuthError(message: 'No token received from server'));
          return;
        }

        debugPrint('[AuthBloc] Got token, storing...');
        await _storage.write(key: TokenKeys.accessToken, value: accessToken);

        final refreshToken = responseData['refreshToken']?.toString() ??
            responseData['refresh_token']?.toString();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await _storage.write(key: TokenKeys.refreshToken, value: refreshToken);
        }

        final user = UserModel.fromJson(responseData['user'] as Map<String, dynamic>);
        debugPrint('[AuthBloc] Login successful for ${user.email}');
        emit(Authenticated(user: user));
      } else if (response.statusCode == 403 &&
          responseData['requires_verification'] == true) {
        emit(EmailVerificationRequired(
          email: (responseData['email'] ?? event.email).toString(),
        ));
      } else {
        emit(AuthError(
            message: responseData['message']?.toString() ??
                responseData['error']?.toString() ??
                'Login failed'));
      }
    } catch (e, stackTrace) {
      debugPrint('[AuthBloc] Login error: $e');
      debugPrint('[AuthBloc] Stack: $stackTrace');
      emit(AuthError(message: 'Login failed: ${e.toString()}'));
    }
  }

  Future<void> _onRegister(
      RegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final roleStr = event.role.name == 'normalUser'
          ? 'normal_user'
          : event.role.name;

      final response = await _dio.post('/auth/register', data: {
        'full_name': event.fullName,
        'email': event.email,
        'password': event.password,
        'role': roleStr,
      });

      Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData = json.decode(response.data as String) as Map<String, dynamic>;
      } else {
        responseData = response.data as Map<String, dynamic>;
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        emit(EmailVerificationRequired(email: event.email));
      } else {
        emit(AuthError(
            message:
                responseData['error']?.toString() ?? 'Registration failed'));
      }
    } catch (e) {
      debugPrint('[AuthBloc] Register error: $e');
      emit(AuthError(message: 'Registration failed: ${e.toString()}'));
    }
  }

  Future<void> _onLogout(
      LogoutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    await _clearTokens();
    emit(const Unauthenticated());
  }

  Future<void> _onUpdateProfile(
      UpdateProfileRequested event, Emitter<AuthState> emit) async {
    if (state is! Authenticated) return;
    final currentUser = (state as Authenticated).user;
    emit(const AuthLoading());

    try {
      final token = await _storage.read(key: TokenKeys.accessToken);
      final data = <String, dynamic>{};
      if (event.fullName != null) data['full_name'] = event.fullName;
      if (event.phoneNumber != null) data['phone_number'] = event.phoneNumber;

      final response = await _dio.put('/auth/profile/${currentUser.id}',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data['user']);
        emit(ProfileUpdated(user: user));
        emit(Authenticated(user: user));
      } else {
        emit(const AuthError(message: 'Profile update failed.'));
        emit(Authenticated(user: currentUser));
      }
    } catch (_) {
      emit(const AuthError(message: 'Profile update failed.'));
      emit(Authenticated(user: currentUser));
    }
  }

  Future<void> _onUploadPicture(UploadProfilePictureRequested event,
      Emitter<AuthState> emit) async {
    if (state is! Authenticated) return;
    final currentUser = (state as Authenticated).user;
    emit(const ProfilePictureUploading());

    try {
      final token = await _storage.read(key: TokenKeys.accessToken);
      
      // Upload the image file to the backend
      final formData = FormData.fromMap({
        'profile_picture': await MultipartFile.fromFile(
          event.imagePath,
          filename: event.imagePath.split('/').last,
        ),
      });

      final uploadDio = Dio(BaseOptions(
        baseUrl: ApiClient.baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ));

      final response = await uploadDio.post(
        '/auth/profile/${currentUser.id}/picture',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final imageUrl = response.data['profile_picture_url'] as String?;
        final updatedUser = currentUser.copyWith(
          profilePictureUrl: imageUrl ?? event.imagePath,
          updatedAt: DateTime.now(),
        );
        emit(ProfilePictureUploaded(user: updatedUser));
        emit(Authenticated(user: updatedUser));
      } else {
        emit(const AuthError(message: 'Upload failed.'));
        emit(Authenticated(user: currentUser));
      }
    } catch (e) {
      debugPrint('[AuthBloc] Upload error: $e');
      emit(AuthError(message: 'Upload failed: ${e.toString()}'));
      emit(Authenticated(user: currentUser));
    }
  }

  Future<void> _onVerificationCompleted(
      VerificationCompleted event, Emitter<AuthState> emit) async {
    await _storage.write(key: TokenKeys.accessToken, value: event.token);

    if (event.refreshToken != null) {
      await _storage.write(
          key: TokenKeys.refreshToken, value: event.refreshToken!);
    }

    final user = UserModel.fromJson(event.userJson);
    emit(Authenticated(user: user));
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _storage.read(key: TokenKeys.refreshToken);
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final refreshDio = Dio(BaseOptions(
        baseUrl: ApiClient.baseUrl,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'] ??
            response.data['token'] ??
            response.data['access_token'];
        final newRefreshToken =
            response.data['refreshToken'] ?? response.data['refresh_token'];

        if (newAccessToken != null) {
          await _storage.write(
              key: TokenKeys.accessToken, value: newAccessToken as String);
        }
        if (newRefreshToken != null) {
          await _storage.write(
              key: TokenKeys.refreshToken, value: newRefreshToken as String);
        }
        return newAccessToken != null;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: TokenKeys.accessToken);
    await _storage.delete(key: TokenKeys.refreshToken);
  }

  /// @deprecated Use `add(VerificationCompleted(...))` instead.
  Future<void> setAuthenticatedFromVerification({
    required String token,
    required Map<String, dynamic> userJson,
  }) async {
    add(VerificationCompleted(token: token, userJson: userJson));
  }
}
