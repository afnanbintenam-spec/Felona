import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/entities/user.dart';
import 'package:felo_na/features/auth/domain/repositories/auth_repository.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';

/// Use case for registering a new user account.
///
/// Validates input and delegates to the AuthRepository to create
/// a new user with the provided credentials and role selection.
/// On success, the repository stores the JWT token.
///
/// Requirements: 1.1, 1.2, 1.3, 1.4, 1.5
class RegisterUseCase extends UseCase<User, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.register(
      email: params.email,
      password: params.password,
      fullName: params.fullName,
      role: params.role,
    );
  }
}

/// Parameters for the [RegisterUseCase].
class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String fullName;
  final String role;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, fullName, role];
}
