import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/widgets/chips/category_chip.dart';
import 'package:felo_na/core/widgets/inputs/search_bar.dart';
import 'package:felo_na/core/widgets/loading/loading_indicator.dart';
import 'package:felo_na/core/widgets/empty_states/empty_state.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_state.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_bloc.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_event.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_state.dart';
import 'package:felo_na/features/marketplace/presentation/widgets/item_card.dart';

/// Marketplace — Klima-inspired clean dark design.
class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  ListingCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    context.read<MarketplaceBloc>().add(const LoadListingsRequested());
  }

  void _onCategorySelected(ListingCategory? category) {
    setState(() => _selectedCategory = category);
    if (category == null) {
      context.read<MarketplaceBloc>().add(const LoadListingsRequested());
    } else {
      context
          .read<MarketplaceBloc>()
          .add(LoadListingsByCategoryRequested(category: category));
    }
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      context.read<MarketplaceBloc>().add(const LoadListingsRequested());
    } else {
      context
          .read<MarketplaceBloc>()
          .add(SearchListingsRequested(query: query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  const Text(
                    'Marketplace',
                    style: TextStyle(
                      fontFamily: 'Finlandica',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/notifications'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.border, width: 1),
                      ),
                      child: const Icon(Icons.notifications_outlined,
                          color: AppColors.textSecondary, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppSearchBar(
                hintText: 'Find items that need a home...',
                onSearch: _onSearch,
              ),
            ),

            // Category Chips
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CategoryChip(
                      label: 'All',
                      isSelected: _selectedCategory == null,
                      onTap: () => _onCategorySelected(null),
                    ),
                  ),
                  ...ListingCategory.values.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CategoryChip(
                        label: category.displayName,
                        isSelected: _selectedCategory == category,
                        onTap: () => _onCategorySelected(category),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Items Grid
            Expanded(
              child: BlocBuilder<MarketplaceBloc, MarketplaceState>(
                builder: (context, state) {
                  if (state is MarketplaceLoading) {
                    return const LoadingIndicator(
                        message: 'Loading listings...');
                  } else if (state is MarketplaceError) {
                    return EmptyState(
                      icon: Icons.error_outline,
                      title: 'Error',
                      description: state.message,
                      actionLabel: 'Retry',
                      onAction: () {
                        context
                            .read<MarketplaceBloc>()
                            .add(const LoadListingsRequested());
                      },
                    );
                  } else if (state is MarketplaceLoaded) {
                    if (state.listings.isEmpty) {
                      final authState = context.read<AuthBloc>().state;
                      final isBuyer = authState is Authenticated &&
                          authState.user.role == UserRole.buyer;
                      return EmptyState(
                        icon: Icons.storefront_outlined,
                        title: 'Nothing Here Yet',
                        description: isBuyer
                            ? 'No items available for purchase yet.\nCheck back soon!'
                            : 'No one has posted anything for sale yet.\nBe the first to list an item!',
                        actionLabel: isBuyer ? null : 'Post an Item',
                        onAction: isBuyer
                            ? null
                            : () {
                                Navigator.pushNamed(
                                    context, '/create-listing');
                              },
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: state.listings.length,
                      itemBuilder: (context, index) {
                        final listing = state.listings[index];
                        return ItemCard(
                          listing: listing,
                          onTap: () {
                            Navigator.pushNamed(context, '/item-detail',
                                arguments: listing);
                          },
                          onFavorite: () {
                            context.read<MarketplaceBloc>().add(
                                ToggleFavoriteRequested(
                                    listingId: listing.id));
                          },
                        );
                      },
                    );
                  }

                  return const EmptyState(
                    icon: Icons.storefront_outlined,
                    title: 'Marketplace',
                    description:
                        'Items posted by sellers will appear here.\nBrowse or list your own items!',
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget? _buildFab() {
    final authState = context.read<AuthBloc>().state;
    final isBuyer =
        authState is Authenticated && authState.user.role == UserRole.buyer;
    if (isBuyer) return null;

    return FloatingActionButton.extended(
      onPressed: () => Navigator.pushNamed(context, '/create-listing'),
      backgroundColor: AppColors.primaryGreen,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'List something',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
