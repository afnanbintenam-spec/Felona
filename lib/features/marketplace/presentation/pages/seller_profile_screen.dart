import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/spacing.dart';
import 'package:felo_na/features/marketplace/domain/entities/listing.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_bloc.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_state.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_event.dart';
import 'package:felo_na/features/marketplace/presentation/pages/item_detail_screen.dart';
import 'package:felo_na/features/messaging/presentation/bloc/messaging_bloc.dart';
import 'package:felo_na/features/messaging/presentation/bloc/messaging_event.dart';
import 'package:felo_na/features/messaging/presentation/bloc/messaging_state.dart';
import 'package:felo_na/features/messaging/presentation/pages/chat_screen.dart';

/// Seller profile screen — shows seller info, ratings, and their listings.
class SellerProfileScreen extends StatefulWidget {
  final String sellerId;
  final String sellerName;
  final String? sellerAvatarUrl;

  const SellerProfileScreen({
    super.key,
    required this.sellerId,
    required this.sellerName,
    this.sellerAvatarUrl,
  });

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<MarketplaceBloc>()
        .add(LoadSellerListingsRequested(sellerId: widget.sellerId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Seller header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.background,
            foregroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_rounded,
                      size: 18, color: Colors.white),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildSellerHeader(),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: Spacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Spacing.gap24,
                  _buildSellerStats(),
                  Spacing.gap24,
                  const Text(
                    'Listings',
                    style: TextStyle(
                      fontFamily: 'Finlandica',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Spacing.gap12,
                ],
              ),
            ),
          ),

          // Listings grid
          BlocBuilder<MarketplaceBloc, MarketplaceState>(
            builder: (context, state) {
              if (state is MarketplaceLoading) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                          color: AppColors.primaryGreen),
                    ),
                  ),
                );
              }

              if (state is SellerListingsLoaded) {
                if (state.listings.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _buildEmptyListings(),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildListingCard(state.listings[index]),
                      childCount: state.listings.length,
                    ),
                  ),
                );
              }

              if (state is MarketplaceError) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        state.message,
                        style: const TextStyle(
                            color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                );
              }

              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSellerHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.deepGreen, AppColors.background],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 48),
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor:
                  AppColors.primaryGreen.withValues(alpha: 0.2),
              backgroundImage: widget.sellerAvatarUrl != null
                  ? NetworkImage(widget.sellerAvatarUrl!)
                  : null,
              child: widget.sellerAvatarUrl == null
                  ? Text(
                      widget.sellerName.isNotEmpty
                          ? widget.sellerName[0].toUpperCase()
                          : 'S',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              widget.sellerName,
              style: const TextStyle(
                fontFamily: 'Finlandica',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Seller',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSellerStats() {
    return BlocBuilder<MarketplaceBloc, MarketplaceState>(
      builder: (context, state) {
        final listingCount = state is SellerListingsLoaded
            ? state.listings.length
            : 0;
        final activeCount = state is SellerListingsLoaded
            ? state.listings
                .where((l) => l.status.name == 'active')
                .length
            : 0;

        return Row(
          children: [
            Expanded(
              child: _statCard(
                  listingCount == 0 ? 'None yet' : '$listingCount',
                  'Listings',
                  Icons.sell_rounded),
            ),
            Spacing.hGap12,
            Expanded(
              child: _statCard(
                  activeCount == 0 ? 'None yet' : '$activeCount',
                  'Active',
                  Icons.check_circle_outline),
            ),
            Spacing.hGap12,
            Expanded(
              child: _statCard(
                  'No rating yet', 'Rating', Icons.star_rounded,
                  iconColor: const Color(0xFFF39C12)),
            ),
          ],
        );
      },
    );
  }

  Widget _statCard(String value, String label, IconData icon,
      {Color iconColor = AppColors.primaryGreen}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          Spacing.gap6,
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Spacing.gap2,
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingCard(Listing listing) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ItemDetailScreen(listing: listing),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15)),
                child: listing.imageUrls.isNotEmpty
                    ? Image.network(
                        listing.imageUrls.first,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '৳${listing.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(Icons.image_outlined,
            color: AppColors.textTertiary, size: 32),
      ),
    );
  }

  Widget _buildEmptyListings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: const Column(
        children: [
          Icon(Icons.storefront_outlined,
              color: AppColors.textTertiary, size: 40),
          SizedBox(height: 12),
          Text(
            'No listings yet',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'This seller hasn\'t posted anything yet.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
