import 'package:dartz/dartz.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/eco_score/domain/entities/eco_stats.dart';
import 'package:felo_na/features/eco_score/domain/repositories/eco_repository.dart';

/// Returns the current user's full eco score statistics and badges.
class GetEcoStatsUseCase extends UseCase<EcoStats, NoParams> {
  final EcoRepository repository;

  GetEcoStatsUseCase(this.repository);

  @override
  Future<Either<Failure, EcoStats>> call(NoParams params) =>
      repository.getEcoStats();
}
