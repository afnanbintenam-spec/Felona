import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/eco_score/domain/repositories/eco_repository.dart';

/// Returns the top eco score leaderboard entries.
class GetLeaderboardUseCase
    extends UseCase<List<Map<String, dynamic>>, GetLeaderboardParams> {
  final EcoRepository repository;

  GetLeaderboardUseCase(this.repository);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(
          GetLeaderboardParams params) =>
      repository.getLeaderboard(limit: params.limit);
}

class GetLeaderboardParams extends Equatable {
  final int limit;

  const GetLeaderboardParams({this.limit = 50});

  @override
  List<Object?> get props => [limit];
}
