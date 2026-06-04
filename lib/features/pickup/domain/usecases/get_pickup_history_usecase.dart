import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/pickup/domain/entities/pickup_request.dart';
import 'package:felo_na/features/pickup/domain/repositories/pickup_repository.dart';

/// Returns paginated pickup history for the current user (or collector).
class GetPickupHistoryUseCase
    extends UseCase<List<PickupRequest>, GetPickupHistoryParams> {
  final PickupRepository repository;

  GetPickupHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<PickupRequest>>> call(
          GetPickupHistoryParams params) =>
      repository.getMyPickupHistory(page: params.page, limit: params.limit);
}

class GetPickupHistoryParams extends Equatable {
  final int page;
  final int limit;

  const GetPickupHistoryParams({this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [page, limit];
}
