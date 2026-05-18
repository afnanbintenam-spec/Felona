import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/app_text_styles.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/widgets/chips/category_chip.dart';
import 'package:felo_na/core/widgets/inputs/search_bar.dart';
import 'package:felo_na/core/widgets/loading/loading_indicator.dart';
import 'package:felo_na/core/widgets/empty_states/empty_state.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_bloc.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_event.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_state.dart';
import 'package:felo_na/features/marketplace/presentation/widgets/item_card.dart';

/// Marketplace screen displaying all listings.
///
/// Features:
/// - Search functionality
/// - Category filtering
/// - Grid layout
/// - BLoC integration
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
    // Load listings when screen initializes
    context.read<MarketplaceBloc>().add(const LoadListingsRequested());
  }

  void _onCategorySelected(ListingCategory? category) {
    setState(() {
      _selectedCategory = category;
    });

    if (category == null) {
      context.read<MarketplaceBloc>().add(const LoadListingsRequested());
    } else {
      context.read<MarketplaceBloc>().add(
            LoadListingsByCategoryRequested(category: category),
          );
    }
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      context.read<MarketplaceBloc>().add(const LoadListingsRequested());
    } else {
      context.read<MarketplaceBloc>().add(
            SearchListingsRequested(query: query),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppSearchBar(
                hintText: 'Search items...',
                onSearch: _onSearch,
              ),
            ),

            // Category Chips
            SizedBox(
              height: 50,
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
                      message: 'Loading listings...',
                    );
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
                      return EmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: 'No Items Found',
                        description: 'There are no listings available at the moment.',
                        actionLabel: 'Create Listing',
                        onAction: () {
                          Navigator.pushNamed(context, '/create-listing');
                        },
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            Navigator.pushNamed(
                              context,
                              '/item-detail',
                              arguments: listing,
                            );
                          },
                          onFavorite: () {
                            context.read<MarketplaceBloc>().add(
                                  ToggleFavoriteRequested(listingId: listing.id),
                                );
                          },
                        );
                      },
                    );
                  }

                  return const EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'Marketplace',
                    description: 'Browse items or create your own listing',
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-listing');
        },
        backgroundColor: AppColors.primary500,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.gray200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Marketplace',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.gray900,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
    );
  }
}
