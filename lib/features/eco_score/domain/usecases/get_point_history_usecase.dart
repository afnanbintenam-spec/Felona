import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/eco_score/domain/entities/eco_stats.dart';
import 'package:felo_na/features/eco_score/domain/repositories/eco_repository.dart';

/// Returns the paginated eco point history for the current user.
class GetPointHistoryUseCase
    extends UseCase<List<PointHistory>, GetPointHistoryParams> {
  final EcoRepository repository;

  GetPointHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<PointHistory>>> call(
          GetPointHistoryParams params) =>
      repository.getPointHistory(page: params.page, limit: params.limit);
}

class GetPointHistoryParams extends Equatable {
  final int page;
  final int limit;

  const GetPointHistoryParams({this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [page, limit];
}
