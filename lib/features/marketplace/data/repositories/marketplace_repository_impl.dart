import 'package:dartz/dartz.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/errors/error_handler.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/marketplace/data/datasources/marketplace_remote_data_source.dart';
import 'package:felo_na/features/marketplace/domain/entities/listing.dart';
import 'package:felo_na/features/marketplace/domain/repositories/marketplace_repository.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final MarketplaceRemoteDataSource _remoteDataSource;

  MarketplaceRepositoryImpl({required MarketplaceRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<Listing>>> getListings({int page = 1, int limit = 20}) async {
    try {
      final listings = await _remoteDataSource.getListings(page: page, limit: limit);
      return Right(listings);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<Listing>>> getListingsByCategory(ListingCategory category) async {
    try {
      final listings = await _remoteDataSource.getListingsByCategory(category);
      return Right(listings);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<Listing>>> searchListings(String query) async {
    try {
      final listings = await _remoteDataSource.searchListings(query);
      return Right(listings);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Listing>> createListing({
    required String title,
    required String description,
    required double price,
    required ListingCategory category,
    required List<String> imagePaths,
    String? location,
  }) async {
    try {
      final listing = await _remoteDataSource.createListing(
        title: title,
        description: description,
        price: price,
        category: category,
        imagePaths: imagePaths,
        location: location,
      );
      return Right(listing);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<Listing>>> getMyListings() async {
    try {
      final listings = await _remoteDataSource.getMyListings();
      return Right(listings);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(String listingId) async {
    try {
      await _remoteDataSource.toggleFavorite(listingId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, Listing>> getListingById(String id) async {
    try {
      final listing = await _remoteDataSource.getListingById(id);
      return Right(listing);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteListing(String id) async {
    try {
      await _remoteDataSource.deleteListing(id);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
}
