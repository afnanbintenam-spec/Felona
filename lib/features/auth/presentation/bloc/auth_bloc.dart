import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:felo_na/core/network/api_client.dart';
import 'package:felo_na/core/network/auth_interceptor.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_event.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_state.dart';
import 'package:felo_na/features/auth/data/models/user_model.dart';

/// AuthBloc — backend-wired with OTP-required registration & token refresh
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthBloc({Dio? dio, FlutterSecureStorage? storage})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: ApiClient.baseUrl,
              headers: {'Content-Type': 'application/json'},
              validateStatus: (s) => s != null && s < 500,
            )),
        _storage = storage ?? const FlutterSecureStorage(),
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

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data['user']);
        emit(Authenticated(user: user));
      } else if (response.statusCode == 401) {
        // Token expired — try refresh
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          // Retry with new token
          final newToken = await _storage.read(key: TokenKeys.accessToken);
          final retryResponse = await _dio.get('/auth/me',
              options: Options(headers: {'Authorization': 'Bearer $newToken'}));
          if (retryResponse.statusCode == 200) {
            final user = UserModel.fromJson(retryResponse.data['user']);
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
      final response = await _dio.post('/auth/login', data: {
        'email': event.email,
        'password': event.password,
      });

      if (response.statusCode == 200) {
        // Store access token (supports both 'token' and 'accessToken' keys)
        final accessToken = (response.data['token'] ??
            response.data['accessToken'] ??
            response.data['access_token']) as String;
        await _storage.write(key: TokenKeys.accessToken, value: accessToken);

        // Store refresh token if provided
        final refreshToken = response.data['refreshToken'] ??
            response.data['refresh_token'];
        if (refreshToken != null) {
          await _storage.write(
              key: TokenKeys.refreshToken, value: refreshToken as String);
        }

        final user = UserModel.fromJson(response.data['user']);
        emit(Authenticated(user: user));
      } else if (response.statusCode == 403 &&
          response.data['requires_verification'] == true) {
        // Email not verified — direct user to OTP
        emit(EmailVerificationRequired(
          email: response.data['email'] ?? event.email,
        ));
      } else {
        emit(AuthError(
            message: response.data?['message']?.toString() ??
                response.data?['error']?.toString() ??
                'Login failed'));
      }
    } catch (e) {
      emit(const AuthError(
          message: 'Connection error. Is the server running?'));
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

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Registration sends OTP — must verify before login
        emit(EmailVerificationRequired(email: event.email));
      } else {
        emit(AuthError(
            message:
                response.data?['error']?.toString() ?? 'Registration failed'));
      }
    } catch (e) {
      emit(const AuthError(
          message: 'Connection error. Is the server running?'));
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
          options:
              Options(headers: {'Authorization': 'Bearer $token'}));

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
      await Future.delayed(const Duration(seconds: 1));
      final updatedUser = currentUser.copyWith(
        profilePictureUrl: event.imagePath,
        updatedAt: DateTime.now(),
      );
      emit(ProfilePictureUploaded(user: updatedUser));
      emit(Authenticated(user: updatedUser));
    } catch (_) {
      emit(const AuthError(message: 'Upload failed.'));
      emit(Authenticated(user: currentUser));
    }
  }

  /// Handles successful OTP email verification.
  /// Stores token and emits Authenticated state.
  Future<void> _onVerificationCompleted(
      VerificationCompleted event, Emitter<AuthState> emit) async {
    await _storage.write(key: TokenKeys.accessToken, value: event.token);

    // Store refresh token if provided
    if (event.refreshToken != null) {
      await _storage.write(
          key: TokenKeys.refreshToken, value: event.refreshToken!);
    }

    final user = UserModel.fromJson(event.userJson);
    emit(Authenticated(user: user));
  }

  /// Attempts to refresh the access token.
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

  /// Clears all stored tokens.
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
