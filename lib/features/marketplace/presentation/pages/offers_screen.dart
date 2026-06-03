import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/app_text_styles.dart';
import 'package:felo_na/core/network/api_client.dart';
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

  final _dio = Dio(BaseOptions(
    baseUrl: ApiClient.baseUrl,
    headers: {'Content-Type': 'application/json'},
    validateStatus: (s) => s != null && s < 500,
  ));
  final _storage = const FlutterSecureStorage();

  List<dynamic> _receivedOffers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      final response = await _dio.get('/offers/received');
      if (response.statusCode == 200) {
        _receivedOffers =
            (response.data['offers'] as List<dynamic>?) ?? [];
      }
    } catch (e) {
      debugPrint('[OffersScreen] load error: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _acceptOffer(dynamic offer) async {
    final offerId = offer['id']?.toString() ?? '';
    if (offerId.isEmpty) return;
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
      final response = await _dio.patch('/offers/$offerId/accept');
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Offer accepted for ${offer['listing_title'] ?? 'item'}'),
            backgroundColor: AppColors.success,
          ));
        }
        await _loadOffers();
      } else {
        _showError(response.data?['message'] ?? 'Accept failed');
      }
    } catch (e) {
      _showError('Accept failed: $e');
    }
  }

  Future<void> _rejectOffer(dynamic offer) async {
    final offerId = offer['id']?.toString() ?? '';
    if (offerId.isEmpty) return;
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
      final response = await _dio.patch('/offers/$offerId/reject');
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Offer rejected for ${offer['listing_title'] ?? 'item'}'),
            backgroundColor: AppColors.error,
          ));
        }
        await _loadOffers();
      } else {
        _showError(response.data?['message'] ?? 'Reject failed');
      }
    } catch (e) {
      _showError('Reject failed: $e');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.error));
  }

  List<dynamic> _filterByStatus(String status) =>
      _receivedOffers.where((o) => o['status'] == status).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2B2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2B2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 20),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.white54),
            onPressed: _loadOffers,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primaryGreen))
          : Column(
              children: [
                // Tabs
                Container(
                  color: const Color(0xFF1A2B2E),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary500,
                    unselectedLabelColor: AppColors.gray500,
                    labelStyle: AppTextStyles.labelLarge,
                    indicatorColor: AppColors.primary500,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Received'),
                      Tab(text: 'Pending'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOffersList(_receivedOffers,
                          isReceived: true),
                      _buildOffersList(
                          _filterByStatus('pending'),
                          isReceived: true),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildOffersList(List<dynamic> offers,
      {required bool isReceived}) {
    if (offers.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.local_offer_outlined,
        title: 'No offers yet',
        message: isReceived
            ? 'When buyers make offers on your items, they\'ll appear here'
            : 'No pending offers at the moment',
        actionText: null,
        onAction: null,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOffers,
      color: AppColors.primaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: offers.length,
        itemBuilder: (context, index) =>
            _buildOfferCard(offers[index]),
      ),
    );
  }

  Widget _buildOfferCard(dynamic offer) {
    final status = offer['status']?.toString() ?? 'pending';
    final isPending = status == 'pending';

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
          // Top row
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.gray200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image_outlined,
                    color: AppColors.gray500, size: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer['listing_title'] ??
                          offer['title'] ??
                          'Item',
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Listed at ৳${offer['listing_price'] ?? offer['item_price'] ?? '—'}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.gray700),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                text: _statusLabel(status),
                color: _statusColor(status),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.gray200),
          const SizedBox(height: 12),
          // Buyer info
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.gray200,
                child: Icon(Icons.person, size: 18, color: AppColors.gray500),
              ),
              const SizedBox(width: 8),
              Text(
                'Offer from ${offer['buyer_name'] ?? offer['user_name'] ?? 'Buyer'}',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.gray700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Offered price
          Row(
            children: [
              Text('Offered Price:',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.gray700)),
              const SizedBox(width: 8),
              Text(
                '৳${offer['amount'] ?? offer['price'] ?? '—'}',
                style: AppTextStyles.headlineMedium
                    .copyWith(color: AppColors.primary500),
              ),
            ],
          ),
          // Action buttons — only for pending offers
          if (isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: 'Accept',
                    onPressed: () => _acceptOffer(offer),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButtonWidget(
                    text: 'Reject',
                    onPressed: () => _rejectOffer(offer),
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

  String _statusLabel(String status) {
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }
}
