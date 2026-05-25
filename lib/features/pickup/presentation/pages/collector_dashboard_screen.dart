import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/spacing.dart';
import 'package:felo_na/core/network/api_client.dart';

/// Collector Dashboard — Role-specific home screen for collectors
class CollectorDashboardScreen extends StatefulWidget {
  const CollectorDashboardScreen({super.key});

  @override
  State<CollectorDashboardScreen> createState() => _CollectorDashboardScreenState();
}

class _CollectorDashboardScreenState extends State<CollectorDashboardScreen> {
  final _dio = Dio(BaseOptions(baseUrl: ApiClient.baseUrl));
  final _storage = const FlutterSecureStorage();

  int _availablePickups = 0;
  int _jobsCompleted = 0;
  double _totalEarned = 0;
  double _weightCollected = 0;
  double _rating = 0;
  Map<String, dynamic>? _activeJob;
  List<dynamic> _recentJobs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }

      // Load available pickups
      try {
        final availableRes = await _dio.get('/pickups/available');
        if (availableRes.statusCode == 200) {
          final pickups = availableRes.data['pickups'] ?? [];
          _availablePickups = pickups.length;
        }
      } catch (_) {}

      // Load collector stats
      try {
        final statsRes = await _dio.get('/pickups/collector/stats');
        if (statsRes.statusCode == 200) {
          _jobsCompleted = statsRes.data['jobsCompleted'] ?? 0;
          _totalEarned = (statsRes.data['totalEarned'] ?? 0).toDouble();
          _weightCollected = (statsRes.data['weightCollected'] ?? 0).toDouble();
          _rating = (statsRes.data['rating'] ?? 0).toDouble();
        }
      } catch (_) {}

      // Load active job
      try {
        final activeRes = await _dio.get('/pickups/active');
        if (activeRes.statusCode == 200 && activeRes.data['pickup'] != null) {
          _activeJob = activeRes.data['pickup'];
        }
      } catch (_) {}

      // Load recent jobs
      try {
        final recentRes = await _dio.get('/pickups/history');
        if (recentRes.statusCode == 200) {
          _recentJobs = (recentRes.data['pickups'] ?? []).take(5).toList();
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
                      _buildAvailablePickupsCard(),
                      Spacing.gap24,
                      if (_activeJob != null) ...[
                        _buildActiveJobCard(),
                        Spacing.gap24,
                      ],
                      _buildStats(),
                      Spacing.gap24,
                      _buildRecentJobs(),
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
            child: Icon(Icons.local_shipping_rounded, color: AppColors.primaryGreen, size: 22),
          ),
        ),
        Spacing.hGap12,
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Collector', style: TextStyle(
                fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500,
                color: AppColors.primaryGreen,
              )),
              SizedBox(height: 2),
              Text('Hello, Collector 👋', style: TextStyle(
                fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              )),
            ],
          ),
        ),
        // Earnings badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primaryGreen, size: 14),
              const SizedBox(width: 4),
              Text(
                '₦${_totalEarned.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── AVAILABLE PICKUPS CARD ───────────────────────────────────
  Widget _buildAvailablePickupsCard() {
    return GestureDetector(
      onTap: () {
        // Navigate to jobs list
      },
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
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '$_availablePickups',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Spacing.hGap16,
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Available Pickups', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w700,
                    color: Colors.white,
                  )),
                  SizedBox(height: 2),
                  Text('Nearby jobs waiting for you', style: TextStyle(
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

  // ─── ACTIVE JOB CARD ──────────────────────────────────────────
  Widget _buildActiveJobCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_car_rounded, color: AppColors.warning, size: 18),
              ),
              Spacing.hGap12,
              const Expanded(
                child: Text('Active Job', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                )),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('In Progress', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                )),
              ),
            ],
          ),
          Spacing.gap12,
          Text(
            _activeJob?['address'] ?? 'Pickup location',
            style: const TextStyle(
              fontFamily: 'Inter', fontSize: 14, color: AppColors.textSecondary,
            ),
          ),
          Spacing.gap4,
          Text(
            'Weight: ${_activeJob?['weight'] ?? '—'} kg • ${_activeJob?['waste_type'] ?? 'Mixed'}',
            style: const TextStyle(
              fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary,
            ),
          ),
          Spacing.gap12,
          GestureDetector(
            onTap: () {
              // Navigate to active job details
            },
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('View Details', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
                  color: Colors.white,
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── STATS ────────────────────────────────────────────────────
  Widget _buildStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _statCard('$_jobsCompleted', 'Jobs Done', Icons.check_circle_rounded)),
            Spacing.hGap12,
            Expanded(child: _statCard('₦${_totalEarned.toStringAsFixed(0)}', 'Earned', Icons.payments_rounded)),
          ],
        ),
        Spacing.gap12,
        Row(
          children: [
            Expanded(child: _statCard('${_weightCollected.toStringAsFixed(1)}kg', 'Collected', Icons.scale_rounded)),
            Spacing.hGap12,
            Expanded(child: _statCard(_rating > 0 ? _rating.toStringAsFixed(1) : '—', 'Rating', Icons.star_rounded)),
          ],
        ),
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
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 20),
          ),
          Spacing.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )),
                Text(label, style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 11, color: AppColors.textTertiary,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── RECENT JOBS ──────────────────────────────────────────────
  Widget _buildRecentJobs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Jobs', style: TextStyle(
          fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        )),
        Spacing.gap12,
        if (_recentJobs.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: const Column(
              children: [
                Icon(Icons.work_off_rounded, color: AppColors.textTertiary, size: 32),
                SizedBox(height: 8),
                Text('No jobs yet', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                )),
                SizedBox(height: 4),
                Text('Accept your first pickup job above', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary,
                )),
              ],
            ),
          )
        else
          ..._recentJobs.map((job) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _jobTile(job),
          )),
      ],
    );
  }

  Widget _jobTile(dynamic job) {
    final status = job['status'] ?? 'completed';
    final Color statusColor;
    final IconData statusIcon;

    switch (status) {
      case 'completed':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'cancelled':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel_rounded;
        break;
      case 'in_progress':
        statusColor = AppColors.warning;
        statusIcon = Icons.directions_car_rounded;
        break;
      default:
        statusColor = AppColors.textTertiary;
        statusIcon = Icons.circle_outlined;
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
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(statusIcon, color: statusColor, size: 18),
          ),
          Spacing.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job['address'] ?? job['location'] ?? 'Pickup',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${job['weight'] ?? '—'}kg • ${job['waste_type'] ?? 'Mixed'}',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₦${job['earnings'] ?? job['price'] ?? '0'}',
            style: const TextStyle(
              fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
