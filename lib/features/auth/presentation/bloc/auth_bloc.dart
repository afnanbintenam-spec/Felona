import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_event.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_state.dart';
import 'package:felo_na/features/auth/domain/entities/user.dart';
import 'package:felo_na/core/constants/enums.dart';

/// BLoC for managing authentication state.
///
/// Handles login, registration, logout, and profile management.
/// In a real app, this would interact with use cases and repositories.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<UploadProfilePictureRequested>(_onUploadProfilePictureRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    // TODO: Check if user is already logged in (check secure storage for token)
    await Future.delayed(const Duration(seconds: 1));
    
    // For now, emit unauthenticated
    emit(const Unauthenticated());
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // TODO: Call login use case
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock user data
      final user = User(
        id: '1',
        fullName: 'John Doe',
        email: event.email,
        role: UserRole.normalUser,
        ecoPoints: 150,
        createdAt: DateTime.now(),
      );

      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // TODO: Call register use case
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock user data
      final user = User(
        id: '1',
        fullName: event.fullName,
        email: event.email,
        role: event.role,
        ecoPoints: 0,
        createdAt: DateTime.now(),
      );

      emit(Authenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // TODO: Call logout use case
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(const Unauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! Authenticated) return;

    final currentUser = (state as Authenticated).user;
    emit(const AuthLoading());

    try {
      // TODO: Call update profile use case
      await Future.delayed(const Duration(seconds: 1));

      final updatedUser = currentUser.copyWith(
        fullName: event.fullName ?? currentUser.fullName,
        phoneNumber: event.phoneNumber ?? currentUser.phoneNumber,
        updatedAt: DateTime.now(),
      );

      emit(ProfileUpdated(user: updatedUser));
      emit(Authenticated(user: updatedUser));
    } catch (e) {
      emit(AuthError(message: e.toString()));
      emit(Authenticated(user: currentUser));
    }
  }

  Future<void> _onUploadProfilePictureRequested(
    UploadProfilePictureRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! Authenticated) return;

    final currentUser = (state as Authenticated).user;
    emit(const ProfilePictureUploading());

    try {
      // TODO: Call upload profile picture use case
      await Future.delayed(const Duration(seconds: 2));

      final updatedUser = currentUser.copyWith(
        profilePictureUrl: event.imagePath, // In real app, this would be the uploaded URL
        updatedAt: DateTime.now(),
      );

      emit(ProfilePictureUploaded(user: updatedUser));
      emit(Authenticated(user: updatedUser));
    } catch (e) {
      emit(AuthError(message: e.toString()));
      emit(Authenticated(user: currentUser));
    }
  }
}
