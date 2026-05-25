import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/spacing.dart';

/// Buyer Dashboard — Role-specific home screen for buyers
class BuyerDashboardScreen extends StatefulWidget {
  const BuyerDashboardScreen({super.key});

  @override
  State<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen> {
  final _dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
  final _storage = const FlutterSecureStorage();
  final _searchController = TextEditingController();

  List<dynamic> _recentOffers = [];
  List<dynamic> _savedItems = [];
  List<dynamic> _recentPurchases = [];
  int _itemsPurchased = 0;
  int _activeOffers = 0;
  double _moneySaved = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }

      // Load offers
      try {
        final offersRes = await _dio.get('/listings/offers/my');
        if (offersRes.statusCode == 200) {
          _recentOffers = (offersRes.data['offers'] ?? []).take(5).toList();
          _activeOffers = _recentOffers.where((o) => o['status'] == 'pending').length;
        }
      } catch (_) {}

      // Load saved items
      try {
        final savedRes = await _dio.get('/listings/saved');
        if (savedRes.statusCode == 200) {
          _savedItems = (savedRes.data['items'] ?? []).take(8).toList();
        }
      } catch (_) {}

      // Load stats
      try {
        final statsRes = await _dio.get('/listings/buyer/stats');
        if (statsRes.statusCode == 200) {
          _itemsPurchased = statsRes.data['itemsPurchased'] ?? 0;
          _moneySaved = (statsRes.data['moneySaved'] ?? 0).toDouble();
        }
      } catch (_) {}

      // Load recent purchases
      try {
        final purchasesRes = await _dio.get('/listings/purchases');
        if (purchasesRes.statusCode == 200) {
          _recentPurchases = (purchasesRes.data['purchases'] ?? []).take(5).toList();
        }
      } catch (_) {}
    } catch (_) {}

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
            : RefreshIndicator(
                color: AppColors.primaryGreen,
                backgroundColor: AppColors.card,
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: Spacing.pagePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Spacing.gap16,
                      _buildHeader(),
                      Spacing.gap24,
                      _buildSearchCard(),
                      Spacing.gap24,
                      _buildQuickStats(),
                      Spacing.gap24,
                      _buildMyOffers(),
                      Spacing.gap24,
                      _buildSavedItems(),
                      Spacing.gap24,
                      _buildRecentPurchases(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.card,
            border: Border.all(color: AppColors.primaryGreen, width: 2),
          ),
          child: const Center(
            child: Icon(Icons.person_rounded, color: AppColors.primaryGreen, size: 24),
          ),
        ),
        Spacing.hGap12,
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Buyer', style: TextStyle(
                fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500,
                color: AppColors.primaryGreen,
              )),
              SizedBox(height: 2),
              Text('Hello, Buyer 👋', style: TextStyle(
                fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              )),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/notifications'),
          child: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary, size: 20),
          ),
        ),
      ],
    );
  }

  // ─── SEARCH CARD ──────────────────────────────────────────────
  Widget _buildSearchCard() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/marketplace'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.3),
              blurRadius: 16, offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_rounded, color: Colors.white, size: 24),
            ),
            Spacing.hGap16,
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Browse Items', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w700,
                    color: Colors.white,
                  )),
                  SizedBox(height: 2),
                  Text('Find great deals on pre-loved items', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 12, color: Colors.white70,
                  )),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }

  // ─── QUICK STATS ──────────────────────────────────────────────
  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(child: _statCard('$_itemsPurchased', 'Purchased', Icons.shopping_bag_rounded)),
        Spacing.hGap12,
        Expanded(child: _statCard('$_activeOffers', 'Active Offers', Icons.local_offer_rounded)),
        Spacing.hGap12,
        Expanded(child: _statCard('₦${_moneySaved.toStringAsFixed(0)}', 'Saved', Icons.savings_rounded)),
      ],
    );
  }

  Widget _statCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 22),
          Spacing.gap8,
          Text(value, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          )),
          Spacing.gap4,
          Text(label, textAlign: TextAlign.center, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 11, color: AppColors.textTertiary,
          )),
        ],
      ),
    );
  }

  // ─── MY OFFERS ────────────────────────────────────────────────
  Widget _buildMyOffers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('My Offers', style: TextStyle(
          fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        )),
        Spacing.gap12,
        if (_recentOffers.isEmpty)
          _emptyState('No offers yet', 'Start browsing to make your first offer')
        else
          ..._recentOffers.map((offer) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _offerTile(offer),
          )),
      ],
    );
  }

  Widget _offerTile(dynamic offer) {
    final status = offer['status'] ?? 'pending';
    final Color statusColor;
    final IconData statusIcon;

    switch (status) {
      case 'accepted':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = AppColors.warning;
        statusIcon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          Spacing.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer['listing_title'] ?? offer['title'] ?? 'Item',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '₦${offer['amount'] ?? offer['price'] ?? '0'}',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status[0].toUpperCase() + status.substring(1),
              style: TextStyle(
                fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SAVED ITEMS ──────────────────────────────────────────────
  Widget _buildSavedItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Saved Items', style: TextStyle(
          fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        )),
        Spacing.gap12,
        if (_savedItems.isEmpty)
          _emptyState('No saved items', 'Tap the heart icon on items you like')
        else
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _savedItems.length,
              separatorBuilder: (_, __) => Spacing.hGap12,
              itemBuilder: (context, index) => _savedItemCard(_savedItems[index]),
            ),
          ),
      ],
    );
  }

  Widget _savedItemCard(dynamic item) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.image_rounded, color: AppColors.primaryGreen, size: 24),
          ),
          Spacing.gap8,
          Text(
            item['title'] ?? 'Item',
            style: const TextStyle(
              fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
          ),
          Spacing.gap4,
          Text(
            '₦${item['price'] ?? '0'}',
            style: const TextStyle(
              fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ─── RECENT PURCHASES ─────────────────────────────────────────
  Widget _buildRecentPurchases() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Purchases', style: TextStyle(
          fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        )),
        Spacing.gap12,
        if (_recentPurchases.isEmpty)
          _emptyState('No purchases yet', 'Your purchase history will appear here')
        else
          ..._recentPurchases.map((purchase) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _purchaseTile(purchase),
          )),
      ],
    );
  }

  Widget _purchaseTile(dynamic purchase) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shopping_bag_rounded, color: AppColors.success, size: 18),
          ),
          Spacing.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  purchase['title'] ?? 'Purchase',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                Text(
                  purchase['date'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₦${purchase['price'] ?? '0'}',
            style: const TextStyle(
              fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ─── EMPTY STATE ──────────────────────────────────────────────
  Widget _emptyState(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, color: AppColors.textTertiary, size: 32),
          Spacing.gap8,
          Text(title, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          )),
          Spacing.gap4,
          Text(subtitle, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary,
          )),
        ],
      ),
    );
  }
}
