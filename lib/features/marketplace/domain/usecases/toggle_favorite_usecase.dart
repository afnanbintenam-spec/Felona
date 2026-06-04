import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/marketplace/domain/repositories/marketplace_repository.dart';

/// Toggles the favourite status of a listing for the current user.
class ToggleFavoriteUseCase extends UseCase<void, ToggleFavoriteParams> {
  final MarketplaceRepository repository;

  ToggleFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleFavoriteParams params) =>
      repository.toggleFavorite(params.listingId);
}

class ToggleFavoriteParams extends Equatable {
  final String listingId;

  const ToggleFavoriteParams({required this.listingId});

  @override
  List<Object?> get props => [listingId];
}
