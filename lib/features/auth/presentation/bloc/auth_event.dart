import 'package:equatable/equatable.dart';
import 'package:felo_na/core/constants/enums.dart';

/// Base class for all authentication events.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when app starts to check authentication status.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Event triggered when user attempts to login.
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Event triggered when user attempts to register.
class RegisterRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  final UserRole role;

  const RegisterRequested({
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [fullName, email, password, role];
}

/// Event triggered when user logs out.
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Event triggered when user updates their profile.
class UpdateProfileRequested extends AuthEvent {
  final String? fullName;
  final String? phoneNumber;

  const UpdateProfileRequested({
    this.fullName,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [fullName, phoneNumber];
}

/// Event triggered when user uploads a profile picture.
class UploadProfilePictureRequested extends AuthEvent {
  final String imagePath;

  const UploadProfilePictureRequested({
    required this.imagePath,
  });

  @override
  List<Object?> get props => [imagePath];
}
