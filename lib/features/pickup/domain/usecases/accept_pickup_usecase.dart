import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/pickup/domain/entities/pickup_request.dart';
import 'package:felo_na/features/pickup/domain/repositories/pickup_repository.dart';

/// Allows a collector to accept an available pickup job.
class AcceptPickupUseCase extends UseCase<PickupRequest, AcceptPickupParams> {
  final PickupRepository repository;

  AcceptPickupUseCase(this.repository);

  @override
  Future<Either<Failure, PickupRequest>> call(AcceptPickupParams params) =>
      repository.acceptPickup(params.pickupId);
}

class AcceptPickupParams extends Equatable {
  final String pickupId;

  const AcceptPickupParams({required this.pickupId});

  @override
  List<Object?> get props => [pickupId];
}
