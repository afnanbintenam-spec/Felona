import 'package:dartz/dartz.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/marketplace/domain/entities/listing.dart';
import 'package:felo_na/features/marketplace/domain/repositories/marketplace_repository.dart';

/// Returns all marketplace listings.
class GetListingsUseCase extends UseCase<List<Listing>, NoParams> {
  final MarketplaceRepository repository;

  GetListingsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Listing>>> call(NoParams params) =>
      repository.getListings();
}
