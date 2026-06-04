import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/pickup/domain/entities/pickup_request.dart';
import 'package:felo_na/features/pickup/domain/repositories/pickup_repository.dart';

/// Updates the status of a pickup (e.g. on_the_way → arrived → completed).
class UpdatePickupStatusUseCase
    extends UseCase<PickupRequest, UpdatePickupStatusParams> {
  final PickupRepository repository;

  UpdatePickupStatusUseCase(this.repository);

  @override
  Future<Either<Failure, PickupRequest>> call(
          UpdatePickupStatusParams params) =>
      repository.updatePickupStatus(params.pickupId, params.newStatus);
}

class UpdatePickupStatusParams extends Equatable {
  final String pickupId;
  final PickupStatus newStatus;

  const UpdatePickupStatusParams({
    required this.pickupId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [pickupId, newStatus];
}
