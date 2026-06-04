import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/marketplace/domain/entities/listing.dart';
import 'package:felo_na/features/marketplace/domain/repositories/marketplace_repository.dart';

/// Returns listings filtered by waste/item category.
class GetListingsByCategoryUseCase
    extends UseCase<List<Listing>, GetListingsByCategoryParams> {
  final MarketplaceRepository repository;

  GetListingsByCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<Listing>>> call(
          GetListingsByCategoryParams params) =>
      repository.getListingsByCategory(params.category);
}

class GetListingsByCategoryParams extends Equatable {
  final ListingCategory category;

  const GetListingsByCategoryParams({required this.category});

  @override
  List<Object?> get props => [category];
}
