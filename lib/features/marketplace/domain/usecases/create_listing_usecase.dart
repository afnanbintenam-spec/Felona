import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/marketplace/domain/entities/listing.dart';
import 'package:felo_na/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:image_picker/image_picker.dart';

/// Creates a new marketplace listing for the authenticated seller.
class CreateListingUseCase extends UseCase<Listing, CreateListingParams> {
  final MarketplaceRepository repository;

  CreateListingUseCase(this.repository);

  @override
  Future<Either<Failure, Listing>> call(CreateListingParams params) =>
      repository.createListing(
        title: params.title,
        description: params.description,
        price: params.price,
        category: params.category,
        images: params.images,
        location: params.location,
      );
}

class CreateListingParams extends Equatable {
  final String title;
  final String description;
  final double price;
  final ListingCategory category;
  final List<XFile> images;
  final String? location;

  const CreateListingParams({
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.images,
    this.location,
  });

  @override
  List<Object?> get props => [title, description, price, category, images, location];
}
