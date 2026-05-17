import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_event.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_state.dart';
import 'package:felo_na/features/marketplace/domain/entities/listing.dart';
import 'package:felo_na/core/constants/enums.dart';

/// BLoC for managing marketplace state.
///
/// Handles listing operations, search, and favorites.
class MarketplaceBloc extends Bloc<MarketplaceEvent, MarketplaceState> {
  MarketplaceBloc() : super(const MarketplaceInitial()) {
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

    try {
      // TODO: Call use case to load listings
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      final listings = _getMockListings();

      emit(MarketplaceLoaded(listings: listings));
    } catch (e) {
      emit(MarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onLoadListingsByCategoryRequested(
    LoadListingsByCategoryRequested event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(const MarketplaceLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final allListings = _getMockListings();
      final filteredListings = allListings
          .where((listing) => listing.category == event.category)
          .toList();

      emit(MarketplaceLoaded(listings: filteredListings));
    } catch (e) {
      emit(MarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onSearchListingsRequested(
    SearchListingsRequested event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(const MarketplaceLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final allListings = _getMockListings();
      final searchResults = allListings
          .where((listing) =>
              listing.title.toLowerCase().contains(event.query.toLowerCase()) ||
              listing.description
                  .toLowerCase()
                  .contains(event.query.toLowerCase()))
          .toList();

      emit(MarketplaceLoaded(listings: searchResults));
    } catch (e) {
      emit(MarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onToggleFavoriteRequested(
    ToggleFavoriteRequested event,
    Emitter<MarketplaceState> emit,
  ) async {
    if (state is MarketplaceLoaded) {
      final currentState = state as MarketplaceLoaded;
      final updatedListings = currentState.listings.map((listing) {
        if (listing.id == event.listingId) {
          return listing.copyWith(isFavorite: !listing.isFavorite);
        }
        return listing;
      }).toList();

      emit(MarketplaceLoaded(listings: updatedListings));
    }
  }

  Future<void> _onCreateListingRequested(
    CreateListingRequested event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(const CreatingListing());

    try {
      // TODO: Call use case to create listing
      await Future.delayed(const Duration(seconds: 2));

      final newListing = Listing(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: event.title,
        description: event.description,
        price: event.price,
        category: event.category,
        imageUrls: event.imagePaths, // In real app, these would be uploaded URLs
        sellerId: 'current-user-id',
        sellerName: 'Current User',
        status: ListingStatus.active,
        createdAt: DateTime.now(),
      );

      emit(ListingCreated(listing: newListing));
    } catch (e) {
      emit(MarketplaceError(message: e.toString()));
    }
  }

  Future<void> _onLoadMyListingsRequested(
    LoadMyListingsRequested event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(const MarketplaceLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock user's listings
      final myListings = _getMockListings().take(3).toList();

      emit(MarketplaceLoaded(listings: myListings));
    } catch (e) {
      emit(MarketplaceError(message: e.toString()));
    }
  }

  // Mock data generator
  List<Listing> _getMockListings() {
    return [
      Listing(
        id: '1',
        title: 'Vintage Wooden Chair',
        description: 'Beautiful vintage wooden chair in excellent condition. Perfect for your home office or dining room.',
        price: 45.00,
        category: ListingCategory.furniture,
        imageUrls: ['https://via.placeholder.com/400'],
        sellerId: 'user1',
        sellerName: 'John Doe',
        status: ListingStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        location: 'Dhaka, Bangladesh',
      ),
      Listing(
        id: '2',
        title: 'Old Laptop - Working Condition',
        description: 'Dell laptop, 4GB RAM, 500GB HDD. Works perfectly, just upgrading to a new one.',
        price: 150.00,
        category: ListingCategory.electronics,
        imageUrls: ['https://via.placeholder.com/400'],
        sellerId: 'user2',
        sellerName: 'Jane Smith',
        status: ListingStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        location: 'Chittagong, Bangladesh',
      ),
      Listing(
        id: '3',
        title: 'Programming Books Collection',
        description: 'Collection of 10 programming books including Clean Code, Design Patterns, and more.',
        price: 80.00,
        category: ListingCategory.books,
        imageUrls: ['https://via.placeholder.com/400'],
        sellerId: 'user3',
        sellerName: 'Mike Johnson',
        status: ListingStatus.active,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        location: 'Sylhet, Bangladesh',
      ),
      Listing(
        id: '4',
        title: 'Microwave Oven',
        description: 'Samsung microwave oven, barely used. Moving to a new place and need to sell.',
        price: 60.00,
        category: ListingCategory.appliances,
        imageUrls: ['https://via.placeholder.com/400'],
        sellerId: 'user4',
        sellerName: 'Sarah Williams',
        status: ListingStatus.active,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        location: 'Dhaka, Bangladesh',
      ),
      Listing(
        id: '5',
        title: 'Office Desk and Chair Set',
        description: 'Complete office furniture set. Desk with drawers and ergonomic chair.',
        price: 120.00,
        category: ListingCategory.office,
        imageUrls: ['https://via.placeholder.com/400'],
        sellerId: 'user5',
        sellerName: 'David Brown',
        status: ListingStatus.active,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        location: 'Rajshahi, Bangladesh',
      ),
    ];
  }
}
