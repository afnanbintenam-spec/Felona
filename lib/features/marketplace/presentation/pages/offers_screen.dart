import 'package:flutter/material.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/app_text_styles.dart';
import 'package:felo_na/core/widgets/navigation/custom_app_bar.dart';
import 'package:felo_na/core/widgets/chips/status_badge.dart';
import 'package:felo_na/core/widgets/buttons/primary_button.dart';
import 'package:felo_na/core/widgets/buttons/text_button_widget.dart';
import 'package:felo_na/core/widgets/empty_states/empty_state_widget.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data
  final List<OfferData> _receivedOffers = [
    OfferData(
      id: '1',
      itemTitle: 'Vintage Glass Bottles',
      itemPrice: 25.00,
      offeredPrice: 20.00,
      buyerName: 'Sarah Johnson',
      buyerAvatar: null,
      status: OfferStatus.pending,
      itemImage: null,
    ),
    OfferData(
      id: '2',
      itemTitle: 'Metal Cans Collection',
      itemPrice: 15.00,
      offeredPrice: 12.00,
      buyerName: 'Mike Chen',
      buyerAvatar: null,
      status: OfferStatus.accepted,
      itemImage: null,
    ),
  ];

  final List<OfferData> _sentOffers = [
    OfferData(
      id: '3',
      itemTitle: 'Plastic Containers Set',
      itemPrice: 30.00,
      offeredPrice: 25.00,
      buyerName: 'John Doe',
      buyerAvatar: null,
      status: OfferStatus.pending,
      itemImage: null,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Offers',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            color: const Color(0xFF0A0A0A),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary500,
              unselectedLabelColor: AppColors.gray500,
              labelStyle: AppTextStyles.labelLarge,
              indicatorColor: AppColors.primary500,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Received'),
                Tab(text: 'Sent'),
              ],
            ),
          ),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOffersList(_receivedOffers, isReceived: true),
                _buildOffersList(_sentOffers, isReceived: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersList(List<OfferData> offers, {required bool isReceived}) {
    if (offers.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.local_offer_outlined,
        title: 'No offers yet',
        message: isReceived
            ? 'When buyers make offers on your items, they\'ll appear here'
            : 'Start browsing the marketplace to make offers',
        actionText: isReceived ? null : 'Browse Marketplace',
        onAction: isReceived
            ? null
            : () {
                Navigator.pushNamed(context, '/marketplace');
              },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        return _buildOfferCard(offers[index], isReceived: isReceived);
      },
    );
  }

  Widget _buildOfferCard(OfferData offer, {required bool isReceived}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Item info and status
          Row(
            children: [
              // Item thumbnail
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.gray200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: offer.itemImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          offer.itemImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.image_outlined,
                        color: AppColors.gray500,
                        size: 32,
                      ),
              ),
              const SizedBox(width: 12),
              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.itemTitle,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Listed at \$${offer.itemPrice.toStringAsFixed(2)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gray700,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              StatusBadge(
                label: _getStatusLabel(offer.status),
                type: _getStatusType(offer.status),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.gray200),
          const SizedBox(height: 12),
          // Buyer/Seller info
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.gray200,
                child: offer.buyerAvatar != null
                    ? ClipOval(
                        child: Image.network(
                          offer.buyerAvatar!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 18,
                        color: AppColors.gray500,
                      ),
              ),
              const SizedBox(width: 8),
              Text(
                isReceived ? 'Offer from ${offer.buyerName}' : offer.buyerName,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Offered price
          Row(
            children: [
              Text(
                'Offered Price:',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${offer.offeredPrice.toStringAsFixed(2)}',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary500,
                ),
              ),
            ],
          ),
          // Action buttons (only for received pending offers)
          if (isReceived && offer.status == OfferStatus.pending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: 'Accept',
                    onPressed: () => _handleAcceptOffer(offer),
                    height: 40,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButtonWidget(
                    text: 'Reject',
                    onPressed: () => _handleRejectOffer(offer),
                    textColor: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getStatusLabel(OfferStatus status) {
    switch (status) {
      case OfferStatus.pending:
        return 'Pending';
      case OfferStatus.accepted:
        return 'Accepted';
      case OfferStatus.rejected:
        return 'Rejected';
    }
  }

  StatusType _getStatusType(OfferStatus status) {
    switch (status) {
      case OfferStatus.pending:
        return StatusType.pending;
      case OfferStatus.accepted:
        return StatusType.completed;
      case OfferStatus.rejected:
        return StatusType.rejected;
    }
  }

  void _handleAcceptOffer(OfferData offer) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Offer accepted for ${offer.itemTitle}'),
        backgroundColor: AppColors.success,
      ),
    );
    // TODO: Implement accept offer logic
  }

  void _handleRejectOffer(OfferData offer) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Offer rejected for ${offer.itemTitle}'),
        backgroundColor: AppColors.error,
      ),
    );
    // TODO: Implement reject offer logic
  }
}

// Models
enum OfferStatus { pending, accepted, rejected }

class OfferData {
  final String id;
  final String itemTitle;
  final double itemPrice;
  final double offeredPrice;
  final String buyerName;
  final String? buyerAvatar;
  final OfferStatus status;
  final String? itemImage;

  OfferData({
    required this.id,
    required this.itemTitle,
    required this.itemPrice,
    required this.offeredPrice,
    required this.buyerName,
    this.buyerAvatar,
    required this.status,
    this.itemImage,
  });
}
