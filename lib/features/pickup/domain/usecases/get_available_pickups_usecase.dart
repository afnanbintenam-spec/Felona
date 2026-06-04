import 'package:dartz/dartz.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/pickup/domain/entities/pickup_request.dart';
import 'package:felo_na/features/pickup/domain/repositories/pickup_repository.dart';

/// Returns the list of unassigned pickups available for collectors to accept.
class GetAvailablePickupsUseCase
    extends UseCase<List<PickupRequest>, NoParams> {
  final PickupRepository repository;

  GetAvailablePickupsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PickupRequest>>> call(NoParams params) =>
      repository.getAvailablePickups();
}
