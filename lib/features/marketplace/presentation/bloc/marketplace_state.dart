import 'package:equatable/equatable.dart';
import 'package:felo_na/features/marketplace/domain/entities/listing.dart';

/// Base class for all marketplace states.
abstract class MarketplaceState extends Equatable {
  const MarketplaceState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class MarketplaceInitial extends MarketplaceState {
  const MarketplaceInitial();
}

/// Loading state.
class MarketplaceLoading extends MarketplaceState {
  const MarketplaceLoading();
}

/// Loaded state with listings.
class MarketplaceLoaded extends MarketplaceState {
  final List<Listing> listings;

  const MarketplaceLoaded({required this.listings});

  @override
  List<Object?> get props => [listings];
}

/// Error state.
class MarketplaceError extends MarketplaceState {
  final String message;

  const MarketplaceError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Listing created successfully.
class ListingCreated extends MarketplaceState {
  final Listing listing;

  const ListingCreated({required this.listing});

  @override
  List<Object?> get props => [listing];
}

/// Creating listing state.
class CreatingListing extends MarketplaceState {
  const CreatingListing();
}
