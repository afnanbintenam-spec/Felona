import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/spacing.dart';
import 'package:felo_na/core/network/api_client.dart';

/// My Offers Screen — Buyer's offer management
class MyOffersScreen extends StatefulWidget {
  const MyOffersScreen({super.key});

  @override
  State<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen>
    with SingleTickerProviderStateMixin {
  final _dio = Dio(BaseOptions(
    baseUrl: ApiClient.baseUrl,
    headers: {'Content-Type': 'application/json'},
  ));
  final _storage = const FlutterSecureStorage();
  late TabController _tabController;

  List<dynamic> _allOffers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOffers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOffers() async {
    setState(() => _loading = true);
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.get('/listings/offers/my');
      if (response.statusCode == 200) {
        _allOffers = response.data['offers'] ?? [];
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  List<dynamic> _filterOffers(String status) {
    if (status == 'all') return _allOffers;
    return _allOffers.where((o) => o['status'] == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: Spacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Spacing.gap16,
                  const Text('My Offers', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
                  Spacing.gap8,
                  Text(
                    '${_allOffers.length} total offers',
                    style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 14, color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Spacing.gap16,

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textTertiary,
                labelStyle: const TextStyle(
                  fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
                ),
                dividerHeight: 0,
                tabs: const [
                  Tab(text: 'Pending'),
                  Tab(text: 'Accepted'),
                  Tab(text: 'All'),
                ],
              ),
            ),
            Spacing.gap16,

            // Content
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOfferList(_filterOffers('pending')),
                        _buildOfferList(_filterOffers('accepted')),
                        _buildOfferList(_filterOffers('all')),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferList(List<dynamic> offers) {
    if (offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined, color: AppColors.textTertiary, size: 48),
            Spacing.gap16,
            const Text('No offers yet', style: TextStyle(
              fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            )),
            Spacing.gap8,
            const Text('Your offers will appear here', style: TextStyle(
              fontFamily: 'Inter', fontSize: 13, color: AppColors.textTertiary,
            )),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOffers,
      color: AppColors.primaryGreen,
      backgroundColor: AppColors.card,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: offers.length,
        separatorBuilder: (_, __) => Spacing.gap12,
        itemBuilder: (context, index) => _buildOfferCard(offers[index]),
      ),
    );
  }

  Widget _buildOfferCard(dynamic offer) {
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusColor, size: 22),
              ),
              Spacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer['listing_title'] ?? offer['title'] ?? 'Item',
                      style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Seller: ${offer['seller_name'] ?? 'Unknown'}',
                      style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
          Spacing.gap12,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your offer: ₦${offer['amount'] ?? offer['price'] ?? '0'}',
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
              Text(
                offer['created_at'] != null
                    ? _formatDate(offer['created_at'])
                    : '',
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 11, color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inDays == 0) return 'Today';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.day}/${date.month}';
    } catch (_) {
      return '';
    }
  }
}
