import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_event.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_state.dart';
import 'package:felo_na/features/marketplace/domain/entities/listing.dart';
import 'package:felo_na/features/marketplace/domain/repositories/marketplace_repository.dart';

/// BLoC for managing marketplace state.
///
/// Handles listing operations, search, and favorites via real API calls.
class MarketplaceBloc extends Bloc<MarketplaceEvent, MarketplaceState> {
  final MarketplaceRepository _repository;

  MarketplaceBloc({required MarketplaceRepository repository})
      : _repository = repository,
        super(const MarketplaceInitial()) {
    on<LoadListingsRequested>(_onLoadListingsRequested);
    on<LoadListingsByCategoryRequested>(_onLoadListingsByCategoryRequested);
    on<SearchListingsRequested>(_onSearchListingsRequested);
    on<ToggleFavoriteRequested>(_onToggleFavoriteRequested);
    on<CreateListingRequested>(_onCreateListingRequested);
    on<LoadMyListingsRequested>(_onLoadMyListingsRequested);
  }

  Future<void> _onLoadListingsRequested(
    LoadListingsRequested event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(const MarketplaceLoading());

    final result = await _repository.getListings();

    result.fold(
      (failure) => emit(MarketplaceError(message: failure.message)),
      (listings) => emit(MarketplaceLoaded(listings: listings)),
    );
  }

  Future<void> _onLoadListingsByCategoryRequested(
    LoadListingsByCategoryRequested event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(const MarketplaceLoading());

    final result = await _repository.getListingsByCategory(event.category);

    result.fold(
      (failure) => emit(MarketplaceError(message: failure.message)),
      (listings) => emit(MarketplaceLoaded(listings: listings)),
    );
  }

  Future<void> _onSearchListingsRequested(
    SearchListingsRequested event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(const MarketplaceLoading());

    final result = await _repository.searchListings(event.query);

    result.fold(
      (failure) => emit(MarketplaceError(message: failure.message)),
      (listings) => emit(MarketplaceLoaded(listings: listings)),
    );
  }

  Future<void> _onToggleFavoriteRequested(
    ToggleFavoriteRequested event,
    Emitter<MarketplaceState> emit,
  ) async {
    if (state is MarketplaceLoaded) {
      final currentState = state as MarketplaceLoaded;

      // Optimistic update
      final updatedListings = currentState.listings.map((listing) {
        if (listing.id == event.listingId) {
          return listing.copyWith(isFavorite: !listing.isFavorite);
        }
        return listing;
      }).toList();

      emit(MarketplaceLoaded(listings: updatedListings));

      // Call API in background
      final result = await _repository.toggleFavorite(event.listingId);
      result.fold(
        (failure) {
          // Revert on failure
          debugPrint('[MarketplaceBloc] Toggle favorite failed: ${failure.message}');
          emit(MarketplaceLoaded(listings: currentState.listings));
        },
        (_) {}, // Success — optimistic update already applied
      );
    }
  }

  Future<void> _onCreateListingRequested(
    CreateListingRequested event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(const CreatingListing());

    final result = await _repository.createListing(
      title: event.title,
      description: event.description,
      price: event.price,
      category: event.category,
      imagePaths: event.imagePaths,
    );

    result.fold(
      (failure) => emit(MarketplaceError(message: failure.message)),
      (listing) => emit(ListingCreated(listing: listing)),
    );
  }

  Future<void> _onLoadMyListingsRequested(
    LoadMyListingsRequested event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(const MarketplaceLoading());

    final result = await _repository.getMyListings();

    result.fold(
      (failure) => emit(MarketplaceError(message: failure.message)),
      (listings) => emit(MarketplaceLoaded(listings: listings)),
    );
  }
}
