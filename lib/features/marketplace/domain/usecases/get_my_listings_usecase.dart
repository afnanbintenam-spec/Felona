import 'package:dartz/dartz.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/marketplace/domain/entities/listing.dart';
import 'package:felo_na/features/marketplace/domain/repositories/marketplace_repository.dart';

/// Returns listings created by the currently authenticated user.
class GetMyListingsUseCase extends UseCase<List<Listing>, NoParams> {
  final MarketplaceRepository repository;

  GetMyListingsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Listing>>> call(NoParams params) =>
      repository.getMyListings();
}
