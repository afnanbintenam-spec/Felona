import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/eco_score/domain/entities/eco_stats.dart';
import 'package:felo_na/features/eco_score/domain/repositories/eco_repository.dart';

/// Awards eco points to the current user for a specific action.
class AddEcoPointsUseCase extends UseCase<EcoStats, AddEcoPointsParams> {
  final EcoRepository repository;

  AddEcoPointsUseCase(this.repository);

  @override
  Future<Either<Failure, EcoStats>> call(AddEcoPointsParams params) =>
      repository.addPoints(
        points: params.points,
        reason: params.reason,
        relatedId: params.relatedId,
      );
}

class AddEcoPointsParams extends Equatable {
  final int points;
  final String reason;
  final String? relatedId;

  const AddEcoPointsParams({
    required this.points,
    required this.reason,
    this.relatedId,
  });

  @override
  List<Object?> get props => [points, reason, relatedId];
}
