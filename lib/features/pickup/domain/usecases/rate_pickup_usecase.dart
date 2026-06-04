import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/pickup/domain/entities/pickup_request.dart';
import 'package:felo_na/features/pickup/domain/repositories/pickup_repository.dart';

/// Submits a rating and optional feedback for a completed pickup.
class RatePickupUseCase extends UseCase<PickupRequest, RatePickupParams> {
  final PickupRepository repository;

  RatePickupUseCase(this.repository);

  @override
  Future<Either<Failure, PickupRequest>> call(RatePickupParams params) =>
      repository.ratePickup(
        pickupId: params.pickupId,
        rating: params.rating,
        feedback: params.feedback,
      );
}

class RatePickupParams extends Equatable {
  final String pickupId;
  final double rating;
  final String? feedback;

  const RatePickupParams({
    required this.pickupId,
    required this.rating,
    this.feedback,
  });

  @override
  List<Object?> get props => [pickupId, rating, feedback];
}
