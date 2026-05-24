import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_event.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_state.dart';
import 'package:felo_na/features/auth/domain/entities/user.dart';
import 'package:felo_na/features/auth/data/models/user_model.dart';

/// AuthBloc — wired to real backend API at localhost:3000
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  static const _baseUrl = 'http://localhost:3000';
  static const _tokenKey = 'auth_token';

  AuthBloc({Dio? dio, FlutterSecureStorage? storage})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: _baseUrl, headers: {'Content-Type': 'application/json'})),
        _storage = storage ?? const FlutterSecureStorage(),
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheck);
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
    on<UpdateProfileRequested>(_onUpdateProfile);
    on<UploadProfilePictureRequested>(_onUploadPicture);
  }

  Future<void> _onAuthCheck(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token == null || token.isEmpty) {
        emit(const Unauthenticated());
        return;
      }

      final response = await _dio.get('/auth/me',
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      final user = UserModel.fromJson(response.data['user']);
      emit(Authenticated(user: user));
    } catch (e) {
      await _storage.delete(key: _tokenKey);
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

      final token = response.data['token'] as String;
      await _storage.write(key: _tokenKey, value: token);

      final user = UserModel.fromJson(response.data['user']);
      emit(Authenticated(user: user));
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Login failed. Please try again.';
      emit(AuthError(message: msg.toString()));
    } catch (e) {
      emit(AuthError(message: 'Connection error. Is the server running?'));
    }
  }

  Future<void> _onRegister(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final roleStr = event.role.name == 'normalUser' ? 'normal_user' : event.role.name;

      final response = await _dio.post('/auth/register', data: {
        'full_name': event.fullName,
        'email': event.email,
        'password': event.password,
        'role': roleStr,
      });

      final token = response.data['token'] as String;
      await _storage.write(key: _tokenKey, value: token);

      final user = UserModel.fromJson(response.data['user']);
      emit(Authenticated(user: user));
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Registration failed.';
      emit(AuthError(message: msg.toString()));
    } catch (e) {
      emit(AuthError(message: 'Connection error. Is the server running?'));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    await _storage.delete(key: _tokenKey);
    emit(const Unauthenticated());
  }

  Future<void> _onUpdateProfile(UpdateProfileRequested event, Emitter<AuthState> emit) async {
    if (state is! Authenticated) return;
    final currentUser = (state as Authenticated).user;
    emit(const AuthLoading());

    try {
      final token = await _storage.read(key: _tokenKey);
      final data = <String, dynamic>{};
      if (event.fullName != null) data['full_name'] = event.fullName;
      if (event.phoneNumber != null) data['phone_number'] = event.phoneNumber;

      final response = await _dio.put('/auth/profile/${currentUser.id}',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}));

      final user = UserModel.fromJson(response.data['user']);
      emit(ProfileUpdated(user: user));
      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: 'Profile update failed.'));
      emit(Authenticated(user: currentUser));
    }
  }

  Future<void> _onUploadPicture(UploadProfilePictureRequested event, Emitter<AuthState> emit) async {
    if (state is! Authenticated) return;
    final currentUser = (state as Authenticated).user;
    emit(const ProfilePictureUploading());

    try {
      // For now, just update the state — real upload needs multipart on mobile
      await Future.delayed(const Duration(seconds: 1));
      final updatedUser = currentUser.copyWith(
        profilePictureUrl: event.imagePath,
        updatedAt: DateTime.now(),
      );
      emit(ProfilePictureUploaded(user: updatedUser));
      emit(Authenticated(user: updatedUser));
    } catch (e) {
      emit(AuthError(message: 'Upload failed.'));
      emit(Authenticated(user: currentUser));
    }
  }
}
