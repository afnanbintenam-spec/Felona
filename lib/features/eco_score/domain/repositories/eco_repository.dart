import 'package:dartz/dartz.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/eco_score/domain/entities/eco_stats.dart';

/// Repository interface for eco score operations.
abstract class EcoRepository {
  Future<Either<Failure, EcoStats>> getEcoStats();
  Future<Either<Failure, List<PointHistory>>> getPointHistory({int page, int limit});
  Future<Either<Failure, EcoStats>> addPoints({
    required int points,
    required String reason,
    String? relatedId,
  });
  Future<Either<Failure, List<Map<String, dynamic>>>> getLeaderboard({int limit});
}
