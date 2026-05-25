import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/spacing.dart';
import 'package:felo_na/core/network/api_client.dart';

/// Collector Earnings Screen — Wallet & earnings overview
class CollectorEarningsScreen extends StatefulWidget {
  const CollectorEarningsScreen({super.key});

  @override
  State<CollectorEarningsScreen> createState() => _CollectorEarningsScreenState();
}

class _CollectorEarningsScreenState extends State<CollectorEarningsScreen> {
  final _dio = Dio(BaseOptions(
    baseUrl: ApiClient.baseUrl,
    headers: {'Content-Type': 'application/json'},
  ));
  final _storage = const FlutterSecureStorage();

  double _totalEarnings = 0;
  double _thisWeek = 0;
  double _thisMonth = 0;
  int _jobsThisWeek = 0;
  List<dynamic> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  Future<void> _loadEarnings() async {
    setState(() => _loading = true);
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }

      // Load earnings stats
      try {
        final statsRes = await _dio.get('/pickups/collector/stats');
        if (statsRes.statusCode == 200) {
          _totalEarnings = (statsRes.data['totalEarned'] ?? 0).toDouble();
          _thisWeek = (statsRes.data['weekEarnings'] ?? 0).toDouble();
          _thisMonth = (statsRes.data['monthEarnings'] ?? 0).toDouble();
          _jobsThisWeek = statsRes.data['weekJobs'] ?? 0;
        }
      } catch (_) {}

      // Load transaction history
      try {
        final txRes = await _dio.get('/pickups/earnings/history');
        if (txRes.statusCode == 200) {
          _transactions = txRes.data['transactions'] ?? [];
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
                onRefresh: _loadEarnings,
                color: AppColors.primaryGreen,
                backgroundColor: AppColors.card,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: Spacing.pagePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Spacing.gap16,
                      const Text('Earnings', style: TextStyle(
                        fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      )),
                      Spacing.gap24,

                      // Total earnings card
                      _buildTotalCard(),
                      Spacing.gap24,

                      // Stats row
                      _buildStatsRow(),
                      Spacing.gap32,

                      // Transaction history
                      const Text('Recent Transactions', style: TextStyle(
                        fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      )),
                      Spacing.gap16,

                      if (_transactions.isEmpty)
                        _buildEmptyTransactions()
                      else
                        ..._transactions.map((tx) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildTransactionTile(tx),
                        )),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen,
            AppColors.primaryGreen.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 20, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Earnings', style: TextStyle(
            fontFamily: 'Inter', fontSize: 14, color: Colors.white70,
          )),
          Spacing.gap8,
          Text(
            '₦${_totalEarnings.toStringAsFixed(0)}',
            style: const TextStyle(
              fontFamily: 'Inter', fontSize: 36, fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Spacing.gap16,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.trending_up_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  '$_jobsThisWeek jobs this week',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _statCard('₦${_thisWeek.toStringAsFixed(0)}', 'This Week', Icons.calendar_today_rounded)),
        Spacing.hGap12,
        Expanded(child: _statCard('₦${_thisMonth.toStringAsFixed(0)}', 'This Month', Icons.date_range_rounded)),
      ],
    );
  }

  Widget _statCard(String value, String label, IconData icon) {
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
          Icon(icon, color: AppColors.primaryGreen, size: 20),
          Spacing.gap12,
          Text(value, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          )),
          Spacing.gap4,
          Text(label, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary,
          )),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: const Column(
        children: [
          Icon(Icons.receipt_long_rounded, color: AppColors.textTertiary, size: 32),
          SizedBox(height: 8),
          Text('No transactions yet', style: TextStyle(
            fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          )),
          SizedBox(height: 4),
          Text('Complete jobs to start earning', style: TextStyle(
            fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary,
          )),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(dynamic tx) {
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
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.add_rounded, color: AppColors.success, size: 20),
          ),
          Spacing.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['description'] ?? tx['address'] ?? 'Pickup completed',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  tx['date'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 12, color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+₦${tx['amount'] ?? tx['earnings'] ?? '0'}',
            style: const TextStyle(
              fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
