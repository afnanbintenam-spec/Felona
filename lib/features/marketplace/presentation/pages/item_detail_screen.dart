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
import 'package:felo_na/features/messaging/presentation/bloc/messaging_bloc.dart';
import 'package:felo_na/features/messaging/presentation/bloc/messaging_event.dart';
import 'package:felo_na/features/messaging/presentation/bloc/messaging_state.dart';
import 'package:felo_na/features/messaging/presentation/pages/chat_screen.dart';

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
  Listing? _listing;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.listing != null) {
      _listing = widget.listing;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_listing == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Listing) {
        setState(() {
          _listing = args;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    if (_listing == null) return;
    context.read<MarketplaceBloc>().add(
          ToggleFavoriteRequested(listingId: _listing!.id),
        );
    setState(() {
      _listing = _listing!.copyWith(isFavorite: !_listing!.isFavorite);
    });
  }

  void _messageSeller() {
    if (_listing == null) return;
    // Open or create a conversation with the seller about this listing
    context.read<MessagingBloc>().add(
          OpenConversationRequested(
            listingId: _listing!.id,
            sellerId: _listing!.sellerId,
            listingTitle: _listing!.title,
          ),
        );
    // Listen for the conversation to open and navigate
    _navigateToChat();
  }

  void _navigateToChat() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<MessagingBloc>(),
        child: _ChatLoadingSheet(listing: _listing!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Handle case where listing is not yet loaded
    final args = ModalRoute.of(context)?.settings.arguments;
    final listing = _listing ?? (args is Listing ? args : widget.listing);

    if (listing == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('No item data available', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    // Cache listing for use in callbacks
    if (_listing == null || _listing != listing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _listing = listing);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image Carousel
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.background,
            foregroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: Colors.white),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: _toggleFavorite,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      listing.isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: listing.isFavorite ? AppColors.error : Colors.white,
                    ),
                  ),
                ),
              ),
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
                              '৳${listing.price.toStringAsFixed(0)}',
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
        Navigator.pushNamed(
          context,
          '/seller-profile',
          arguments: {
            'sellerId': listing.sellerId,
            'sellerName': listing.sellerName,
            'sellerAvatarUrl': listing.sellerAvatarUrl,
          },
        );
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
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
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
                text: 'Purchase',
                onPressed: _showPurchaseSheet,
                icon: Icons.shopping_bag_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPurchaseSheet() {
    if (_listing == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPurchaseBottomSheet(),
    );
  }

  Widget _buildPurchaseBottomSheet() {
    final addressController = TextEditingController();
    final phoneController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.card,
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
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                const Text(
                  'Purchase Item',
                  style: TextStyle(
                    fontFamily: 'Finlandica',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_listing?.title ?? ''} — ৳${_listing?.price.toStringAsFixed(0) ?? '0'}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'A pickup rider will deliver this item to your address.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 20),
                // Delivery Address
                TextField(
                  controller: addressController,
                  maxLines: 2,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Delivery Address',
                    labelStyle: const TextStyle(color: AppColors.textTertiary),
                    hintText: 'Enter your full delivery address',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.location_on_outlined,
                        color: AppColors.primaryGreen),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primaryGreen, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Phone
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Your Phone Number',
                    labelStyle: const TextStyle(color: AppColors.textTertiary),
                    hintText: 'e.g. +880 1700 000000',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.phone_outlined,
                        color: AppColors.primaryGreen),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primaryGreen, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Submit button
                PrimaryButton(
                  text: 'Confirm Purchase',
                  icon: Icons.check_rounded,
                  onPressed: () {
                    if (addressController.text.trim().length < 10) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a complete delivery address'),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                      return;
                    }
                    if (phoneController.text.trim().length < 7) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid phone number'),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    _submitPurchase(
                      addressController.text.trim(),
                      phoneController.text.trim(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitPurchase(String address, String phone) {
    if (_listing == null) return;
    // Submit offer at listed price with delivery info in message
    final offerMessage = 'DELIVERY_ADDRESS:$address|PHONE:$phone';

    // Use the existing offer API
    context.read<MarketplaceBloc>().add(
          MakeOfferRequested(
            listingId: _listing!.id,
            amount: _listing!.price,
            message: offerMessage,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Purchase request sent! The seller will confirm and a rider will deliver to you.'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 4),
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

/// Bottom sheet shown while a conversation is being opened/created.
/// Navigates to ChatScreen once the conversation is ready.
class _ChatLoadingSheet extends StatefulWidget {
  final Listing listing;
  const _ChatLoadingSheet({required this.listing});

  @override
  State<_ChatLoadingSheet> createState() => _ChatLoadingSheetState();
}

class _ChatLoadingSheetState extends State<_ChatLoadingSheet> {
  @override
  void initState() {
    super.initState();
    context.read<MessagingBloc>().add(
          OpenConversationRequested(
            listingId: widget.listing.id,
            sellerId: widget.listing.sellerId,
            listingTitle: widget.listing.title,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MessagingBloc, MessagingState>(
      listener: (context, state) {
        if (state is ConversationOpened) {
          Navigator.pop(context); // close sheet
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<MessagingBloc>(),
                child: ChatScreen(conversation: state.conversation),
              ),
            ),
          );
        } else if (state is MessagingError) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open chat: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Container(
        height: 140,
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryGreen),
            SizedBox(height: 16),
            Text(
              'Opening conversation…',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
