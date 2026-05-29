import 'package:dartz/dartz.dart';
import 'package:felo_na/core/errors/error_handler.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/eco_score/data/datasources/eco_remote_data_source.dart';
import 'package:felo_na/features/eco_score/domain/entities/eco_stats.dart';
import 'package:felo_na/features/eco_score/domain/repositories/eco_repository.dart';

class EcoRepositoryImpl implements EcoRepository {
  final EcoRemoteDataSource _remoteDataSource;

  EcoRepositoryImpl({required EcoRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, EcoStats>> getEcoStats() async {
    try {
      final stats = await _remoteDataSource.getEcoStats();
      return Right(stats);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<PointHistory>>> getPointHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final history = await _remoteDataSource.getPointHistory(page: page, limit: limit);
      return Right(history);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, EcoStats>> addPoints({
    required int points,
    required String reason,
    String? relatedId,
  }) async {
    try {
      final stats = await _remoteDataSource.addPoints(
        points: points,
        reason: reason,
        relatedId: relatedId,
      );
      return Right(stats);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getLeaderboard({int limit = 20}) async {
    try {
      final leaderboard = await _remoteDataSource.getLeaderboard(limit: limit);
      return Right(leaderboard);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
}
