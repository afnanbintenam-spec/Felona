import 'package:dartz/dartz.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/repositories/auth_repository.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';

/// Use case for logging out the current user.
///
/// Delegates to the AuthRepository to clear the stored JWT token
/// and any cached user data. This operation always succeeds locally,
/// even if the server cannot be reached to invalidate the token.
///
/// Requirements: 2.3
class LogoutUseCase extends UseCase<void, NoParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}
