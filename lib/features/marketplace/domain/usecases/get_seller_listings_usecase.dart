import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/marketplace/domain/entities/listing.dart';
import 'package:felo_na/features/marketplace/domain/repositories/marketplace_repository.dart';

/// Returns all public listings for a specific seller profile.
class GetSellerListingsUseCase
    extends UseCase<List<Listing>, GetSellerListingsParams> {
  final MarketplaceRepository repository;

  GetSellerListingsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Listing>>> call(GetSellerListingsParams params) =>
      repository.getSellerListings(params.sellerId);
}

class GetSellerListingsParams extends Equatable {
  final String sellerId;

  const GetSellerListingsParams({required this.sellerId});

  @override
  List<Object?> get props => [sellerId];
}
