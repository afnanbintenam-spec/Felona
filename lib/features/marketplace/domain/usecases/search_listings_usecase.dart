import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/marketplace/domain/entities/listing.dart';
import 'package:felo_na/features/marketplace/domain/repositories/marketplace_repository.dart';

/// Full-text search across marketplace listings.
class SearchListingsUseCase extends UseCase<List<Listing>, SearchListingsParams> {
  final MarketplaceRepository repository;

  SearchListingsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Listing>>> call(SearchListingsParams params) =>
      repository.searchListings(params.query);
}

class SearchListingsParams extends Equatable {
  final String query;

  const SearchListingsParams({required this.query});

  @override
  List<Object?> get props => [query];
}
