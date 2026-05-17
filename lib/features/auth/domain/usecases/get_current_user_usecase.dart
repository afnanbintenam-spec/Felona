import 'package:dartz/dartz.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/entities/user.dart';
import 'package:felo_na/features/auth/domain/repositories/auth_repository.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';

/// Use case for retrieving the currently authenticated user.
///
/// Checks for a valid JWT token and returns the associated user data.
/// Returns null if no user is authenticated or the token has expired.
///
/// Requirements: 2.3
class GetCurrentUserUseCase extends UseCase<User?, NoParams> {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, User?>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}
