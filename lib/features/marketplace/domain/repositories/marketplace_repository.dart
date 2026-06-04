import 'package:dartz/dartz.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/marketplace/domain/entities/listing.dart';
import 'package:image_picker/image_picker.dart';

/// Repository interface for marketplace operations.
abstract class MarketplaceRepository {
  Future<Either<Failure, List<Listing>>> getListings({int page, int limit});
  Future<Either<Failure, List<Listing>>> getListingsByCategory(ListingCategory category);
  Future<Either<Failure, List<Listing>>> searchListings(String query);
  Future<Either<Failure, Listing>> createListing({
    required String title,
    required String description,
    required double price,
    required ListingCategory category,
    required List<XFile> images,
    String? location,
  });
  Future<Either<Failure, List<Listing>>> getMyListings();
  Future<Either<Failure, void>> toggleFavorite(String listingId);
  Future<Either<Failure, Listing>> getListingById(String id);
  Future<Either<Failure, void>> deleteListing(String id);
  Future<Either<Failure, List<Listing>>> getSellerListings(String sellerId);
}
