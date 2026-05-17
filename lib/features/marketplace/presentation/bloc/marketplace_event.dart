import 'package:equatable/equatable.dart';
import 'package:felo_na/core/constants/enums.dart';

/// Base class for all marketplace events.
abstract class MarketplaceEvent extends Equatable {
  const MarketplaceEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all listings.
class LoadListingsRequested extends MarketplaceEvent {
  const LoadListingsRequested();
}

/// Event to load listings by category.
class LoadListingsByCategoryRequested extends MarketplaceEvent {
  final ListingCategory category;

  const LoadListingsByCategoryRequested({required this.category});

  @override
  List<Object?> get props => [category];
}

/// Event to search listings.
class SearchListingsRequested extends MarketplaceEvent {
  final String query;

  const SearchListingsRequested({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Event to toggle favorite status.
class ToggleFavoriteRequested extends MarketplaceEvent {
  final String listingId;

  const ToggleFavoriteRequested({required this.listingId});

  @override
  List<Object?> get props => [listingId];
}

/// Event to create a new listing.
class CreateListingRequested extends MarketplaceEvent {
  final String title;
  final String description;
  final double price;
  final ListingCategory category;
  final List<String> imagePaths;

  const CreateListingRequested({
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.imagePaths,
  });

  @override
  List<Object?> get props => [title, description, price, category, imagePaths];
}

/// Event to load user's own listings.
class LoadMyListingsRequested extends MarketplaceEvent {
  const LoadMyListingsRequested();
}
