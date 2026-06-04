import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/pickup/domain/entities/pickup_request.dart';
import 'package:felo_na/features/pickup/domain/repositories/pickup_repository.dart';

/// Verifies a pickup completion by validating the user's QR token.
class VerifyPickupQrUseCase
    extends UseCase<PickupRequest, VerifyPickupQrParams> {
  final PickupRepository repository;

  VerifyPickupQrUseCase(this.repository);

  @override
  Future<Either<Failure, PickupRequest>> call(VerifyPickupQrParams params) =>
      repository.verifyPickupQr(
        pickupId: params.pickupId,
        qrToken: params.qrToken,
      );
}

class VerifyPickupQrParams extends Equatable {
  final String pickupId;
  final String qrToken;

  const VerifyPickupQrParams({
    required this.pickupId,
    required this.qrToken,
  });

  @override
  List<Object?> get props => [pickupId, qrToken];
}
