import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/entities/user.dart';
import 'package:felo_na/features/auth/domain/repositories/auth_repository.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';

/// Use case for updating the authenticated user's profile information.
///
/// Allows updating full name and phone number. Email and role
/// cannot be changed through this use case.
///
/// Requirements: 3.1
class UpdateProfileUseCase extends UseCase<User, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      userId: params.userId,
      fullName: params.fullName,
      phoneNumber: params.phoneNumber,
    );
  }
}

/// Parameters for the [UpdateProfileUseCase].
class UpdateProfileParams extends Equatable {
  final String userId;
  final String? fullName;
  final String? phoneNumber;

  const UpdateProfileParams({
    required this.userId,
    this.fullName,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [userId, fullName, phoneNumber];
}
