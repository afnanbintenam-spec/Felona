import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/app_text_styles.dart';
import 'package:felo_na/core/widgets/buttons/primary_button.dart';
import 'package:felo_na/core/widgets/buttons/secondary_button.dart';
import 'package:felo_na/core/widgets/chips/status_badge.dart';
import 'package:felo_na/features/marketplace/domain/entities/listing.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_bloc.dart';
import 'package:felo_na/features/marketplace/presentation/bloc/marketplace_event.dart';

/// Item detail screen showing full listing information.
///
/// Features:
/// - Image carousel
/// - Full description
/// - Seller information
/// - Action buttons (Message, Make Offer)
/// - Favorite toggle
class ItemDetailScreen extends StatefulWidget {
  final Listing? listing;

  const ItemDetailScreen({
    super.key,
    this.listing,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late PageController _pageController;
  int _currentImageIndex = 0;
  late Listing _listing;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Get listing from arguments or use provided listing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Listing) {
        setState(() {
          _listing = args;
        });
      } else if (widget.listing != null) {
        _listing = widget.listing!;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    context.read<MarketplaceBloc>().add(
          ToggleFavoriteRequested(listingId: _listing.id),
        );
    setState(() {
      _listing = _listing.copyWith(isFavorite: !_listing.isFavorite);
    });
  }

  void _makeOffer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOfferBottomSheet(),
    );
  }

  void _messageSeller() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chat feature coming soon!'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Handle case where listing is not yet loaded
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null && widget.listing == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Item Details'),
        ),
        body: const Center(
          child: Text('No item data available'),
        ),
      );
    }

    final listing = args as Listing? ?? widget.listing!;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image Carousel
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.gray900,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    listing.isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: listing.isFavorite ? AppColors.error : AppColors.gray900,
                  ),
                ),
                onPressed: _toggleFavorite,
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageCarousel(listing),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price and Title
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '\$${listing.price.toStringAsFixed(2)}',
                              style: AppTextStyles.displayMedium.copyWith(
                                color: AppColors.primary500,
                              ),
                            ),
                          ),
                          StatusBadge.listing(listing.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        listing.title,
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 16,
                            color: AppColors.gray500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            listing.category.displayName,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.gray600,
                            ),
                          ),
                          if (listing.location != null) ...[
                            const SizedBox(width: 16),
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColors.gray500,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                listing.location!,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.gray600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Seller Info
                _buildSellerInfo(listing),

                const Divider(height: 1),

                // Description
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        listing.description,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.gray700,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Posted Date
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.gray500,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Posted ${_getTimeAgo(listing.createdAt)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80), // Space for bottom bar
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(listing),
    );
  }

  Widget _buildImageCarousel(Listing listing) {
    if (listing.imageUrls.isEmpty) {
      return Container(
        color: AppColors.gray200,
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: 80,
            color: AppColors.gray400,
          ),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: listing.imageUrls.length,
          itemBuilder: (context, index) {
            return Image.network(
              listing.imageUrls[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.gray200,
                  child: Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 80,
                      color: AppColors.gray400,
                    ),
                  ),
                );
              },
            );
          },
        ),
        if (listing.imageUrls.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                listing.imageUrls.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentImageIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentImageIndex == index
                        ? AppColors.white
                        : AppColors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSellerInfo(Listing listing) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to seller profile
      },
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary100,
              backgroundImage: listing.sellerAvatarUrl != null
                  ? NetworkImage(listing.sellerAvatarUrl!)
                  : null,
              child: listing.sellerAvatarUrl == null
                  ? Text(
                      listing.sellerName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary500,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.sellerName,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Seller',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(Listing listing) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: 'Message Seller',
                onPressed: _messageSeller,
                icon: Icons.chat_bubble_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                text: 'Make Offer',
                onPressed: _makeOffer,
                icon: Icons.local_offer_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferBottomSheet() {
    final offerController = TextEditingController();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              'Make an Offer',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Listed price: \$${_listing.price.toStringAsFixed(2)}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 24),
            // Offer input
            TextField(
              controller: offerController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Your Offer',
                hintText: 'Enter amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Submit button
            PrimaryButton(
              text: 'Submit Offer',
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Offer submitted successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
