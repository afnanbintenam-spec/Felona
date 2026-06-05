import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/features/marketplace/domain/entities/listing.dart';

/// Item card widget for displaying marketplace listings.
///
/// Features:
/// - Image with gradient overlay (CachedNetworkImage with category fallbacks)
/// - Title, price in BDT (৳), and seller info
/// - Favorite button
/// - Tap to view details
class ItemCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;

  const ItemCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.onFavorite,
  });

  /// Returns a relevant Unsplash placeholder image URL based on listing category.
  /// These are freely embeddable, attribution-free images from Unsplash.
  String _placeholderImageUrl(ListingCategory category) {
    // Curated Unsplash photos per category (w=400 for performance)
    switch (category) {
      case ListingCategory.plastic:
        return 'https://images.unsplash.com/photo-1604187351574-c75ca79f5807?w=400&fit=crop';
      case ListingCategory.metal:
        return 'https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=400&fit=crop';
      case ListingCategory.paper:
        return 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=400&fit=crop';
      case ListingCategory.glass:
        return 'https://images.unsplash.com/photo-1542601906897-ecd4d0a2b228?w=400&fit=crop';
      case ListingCategory.electronics:
        return 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400&fit=crop';
      case ListingCategory.textile:
        return 'https://images.unsplash.com/photo-1558171813-4c088753af8f?w=400&fit=crop';
      case ListingCategory.furniture:
        return 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&fit=crop';
      case ListingCategory.other:
        return 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&fit=crop';
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = listing.imageUrls.isNotEmpty
        ? listing.imageUrls.first
        : _placeholderImageUrl(listing.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with favorite button and price overlay
            Stack(
              children: [
                // Image — CachedNetworkImage for performance & offline caching
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 160,
                      color: AppColors.gray200,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary500,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 160,
                      color: AppColors.gray200,
                      child: Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: AppColors.gray400,
                        ),
                      ),
                    ),
                  ),
                ),
                // Gradient overlay
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
                // Favorite button
                if (onFavorite != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          listing.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 20,
                          color: listing.isFavorite
                              ? AppColors.error
                              : AppColors.gray700,
                        ),
                      ),
                    ),
                  ),
                // Price tag — in Bangladeshi Taka (৳)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary500,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '৳${listing.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    listing.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Seller
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: AppColors.gray500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          listing.sellerName,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.gray600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (listing.location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.gray500,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listing.location!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.gray600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
