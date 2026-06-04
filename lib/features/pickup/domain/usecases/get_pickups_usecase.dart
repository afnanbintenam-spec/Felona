import 'package:dartz/dartz.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/pickup/domain/entities/pickup_request.dart';
import 'package:felo_na/features/pickup/domain/repositories/pickup_repository.dart';

/// Returns the current user's active pickup requests.
class GetPickupsUseCase extends UseCase<List<PickupRequest>, NoParams> {
  final PickupRepository repository;

  GetPickupsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PickupRequest>>> call(NoParams params) =>
      repository.getPickups();
}
