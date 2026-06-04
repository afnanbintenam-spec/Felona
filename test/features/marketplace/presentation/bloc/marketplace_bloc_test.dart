import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/marketplace/domain/entities/listing.dart';
import 'package:felo_na/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_bloc.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_event.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_state.dart';

import 'marketplace_bloc_test.mocks.dart';

@GenerateMocks([MarketplaceRepository])
void main() {
  late MockMarketplaceRepository mockRepository;
  late MarketplaceBloc bloc;

  // ── shared test data ────────────────────────────────────────────────────
  final tListing = Listing(
    id: 'listing-1',
    title: 'Old Laptop',
    description: 'Works great',
    price: 4500,
    category: ListingCategory.electronics,
    imageUrls: const ['https://example.com/img.jpg'],
    sellerId: 'user-1',
    sellerName: 'Rahim',
    status: ListingStatus.active,
    createdAt: DateTime(2025, 1, 1),
  );

  setUp(() {
    mockRepository = MockMarketplaceRepository();
    bloc = MarketplaceBloc(repository: mockRepository);
  });

  tearDown(() => bloc.close());

  // ── LoadListingsRequested ───────────────────────────────────────────────
  group('LoadListingsRequested', () {
    blocTest<MarketplaceBloc, MarketplaceState>(
      'emits [Loading, Loaded] when repository returns listings',
      build: () {
        when(mockRepository.getListings())
            .thenAnswer((_) async => Right([tListing]));
        return bloc;
      },
      act: (b) => b.add(const LoadListingsRequested()),
      expect: () => [
        const MarketplaceLoading(),
        MarketplaceLoaded(listings: [tListing]),
      ],
      verify: (_) => verify(mockRepository.getListings()).called(1),
    );

    blocTest<MarketplaceBloc, MarketplaceState>(
      'emits [Loading, Error] when repository returns a failure',
      build: () {
        when(mockRepository.getListings()).thenAnswer(
          (_) async => const Left(NetworkFailure('No internet')),
        );
        return bloc;
      },
      act: (b) => b.add(const LoadListingsRequested()),
      expect: () => [
        const MarketplaceLoading(),
        const MarketplaceError(message: 'No internet'),
      ],
    );

    blocTest<MarketplaceBloc, MarketplaceState>(
      'emits [Loading, Loaded] with empty list when there are no listings',
      build: () {
        when(mockRepository.getListings())
            .thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (b) => b.add(const LoadListingsRequested()),
      expect: () => [
        const MarketplaceLoading(),
        const MarketplaceLoaded(listings: []),
      ],
    );
  });

  // ── SearchListingsRequested ─────────────────────────────────────────────
  group('SearchListingsRequested', () {
    blocTest<MarketplaceBloc, MarketplaceState>(
      'emits [Loading, Loaded] with filtered results on search',
      build: () {
        when(mockRepository.searchListings('laptop'))
            .thenAnswer((_) async => Right([tListing]));
        return bloc;
      },
      act: (b) => b.add(const SearchListingsRequested(query: 'laptop')),
      expect: () => [
        const MarketplaceLoading(),
        MarketplaceLoaded(listings: [tListing]),
      ],
      verify: (_) =>
          verify(mockRepository.searchListings('laptop')).called(1),
    );

    blocTest<MarketplaceBloc, MarketplaceState>(
      'emits [Loading, Error] when search fails',
      build: () {
        when(mockRepository.searchListings('x')).thenAnswer(
          (_) async => const Left(ServerFailure('Server error', 500)),
        );
        return bloc;
      },
      act: (b) => b.add(const SearchListingsRequested(query: 'x')),
      expect: () => [
        const MarketplaceLoading(),
        const MarketplaceError(message: 'Server error'),
      ],
    );
  });

  // ── CreateListingRequested ──────────────────────────────────────────────
  group('CreateListingRequested', () {
    blocTest<MarketplaceBloc, MarketplaceState>(
      'emits [CreatingListing, ListingCreated] on success',
      build: () {
        when(mockRepository.createListing(
          title: 'Old Laptop',
          description: 'Works great',
          price: 4500,
          category: ListingCategory.electronics,
          imagePaths: const [],
          location: null,
        )).thenAnswer((_) async => Right(tListing));
        return bloc;
      },
      act: (b) => b.add(const CreateListingRequested(
        title: 'Old Laptop',
        description: 'Works great',
        price: 4500,
        category: ListingCategory.electronics,
        imagePaths: [],
      )),
      expect: () => [
        const CreatingListing(),
        ListingCreated(listing: tListing),
      ],
    );

    blocTest<MarketplaceBloc, MarketplaceState>(
      'emits [CreatingListing, Error] when creation fails',
      build: () {
        when(mockRepository.createListing(
          title: anyNamed('title'),
          description: anyNamed('description'),
          price: anyNamed('price'),
          category: anyNamed('category'),
          imagePaths: anyNamed('imagePaths'),
          location: anyNamed('location'),
        )).thenAnswer(
          (_) async =>
              const Left(ValidationFailure('Title required', {'title': 'required'})),
        );
        return bloc;
      },
      act: (b) => b.add(const CreateListingRequested(
        title: '',
        description: '',
        price: 0,
        category: ListingCategory.scrap,
        imagePaths: [],
      )),
      expect: () => [
        const CreatingListing(),
        const MarketplaceError(message: 'Title required'),
      ],
    );
  });

  // ── ToggleFavoriteRequested ─────────────────────────────────────────────
  group('ToggleFavoriteRequested', () {
    blocTest<MarketplaceBloc, MarketplaceState>(
      'optimistically toggles favourite flag and succeeds silently',
      build: () {
        when(mockRepository.getListings())
            .thenAnswer((_) async => Right([tListing]));
        when(mockRepository.toggleFavorite('listing-1'))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (b) async {
        b.add(const LoadListingsRequested());
        await Future.delayed(Duration.zero);
        b.add(const ToggleFavoriteRequested(listingId: 'listing-1'));
      },
      skip: 2, // skip Loading + initial Loaded
      expect: () => [
        MarketplaceLoaded(listings: [tListing.copyWith(isFavorite: true)]),
      ],
    );
  });
}
