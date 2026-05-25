import 'package:equatable/equatable.dart';
import 'package:felo_na/features/auth/domain/entities/user.dart';

/// Base class for all authentication states.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the app starts.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State when authentication operation is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State when user is authenticated.
class Authenticated extends AuthState {
  final User user;

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// State when user is not authenticated.
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// State when an authentication error occurs.
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State when registration succeeded but email verification is required.
class EmailVerificationRequired extends AuthState {
  final String email;

  const EmailVerificationRequired({required this.email});

  @override
  List<Object?> get props => [email];
}

/// State when profile is successfully updated.
class ProfileUpdated extends AuthState {
  final User user;

  const ProfileUpdated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// State when profile picture is being uploaded.
class ProfilePictureUploading extends AuthState {
  const ProfilePictureUploading();
}

/// State when profile picture is successfully uploaded.
class ProfilePictureUploaded extends AuthState {
  final User user;

  const ProfilePictureUploaded({required this.user});

  @override
  List<Object?> get props => [user];
}
