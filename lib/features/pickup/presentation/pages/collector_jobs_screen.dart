import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/spacing.dart';
import 'package:felo_na/core/network/api_client.dart';

/// Collector Jobs Screen — Available pickup jobs to accept
class CollectorJobsScreen extends StatefulWidget {
  const CollectorJobsScreen({super.key});

  @override
  State<CollectorJobsScreen> createState() => _CollectorJobsScreenState();
}

class _CollectorJobsScreenState extends State<CollectorJobsScreen> {
  final _dio = Dio(BaseOptions(
    baseUrl: ApiClient.baseUrl,
    headers: {'Content-Type': 'application/json'},
  ));
  final _storage = const FlutterSecureStorage();

  List<dynamic> _availableJobs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() => _loading = true);
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.get('/pickups/available');
      if (response.statusCode == 200) {
        _availableJobs = response.data['pickups'] ?? [];
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _acceptJob(String pickupId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.post(
        '/pickups/$pickupId/accept',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job accepted! Head to the pickup location.'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadJobs(); // Refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['error'] ?? 'Failed to accept job'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection error'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
                  const Text('Available Jobs', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
                  Spacing.gap8,
                  Text(
                    '${_availableJobs.length} pickups nearby',
                    style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 14, color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Spacing.gap16,

            // Jobs list
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                  : _availableJobs.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadJobs,
                          color: AppColors.primaryGreen,
                          backgroundColor: AppColors.card,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _availableJobs.length,
                            separatorBuilder: (_, __) => Spacing.gap12,
                            itemBuilder: (context, index) =>
                                _buildJobCard(_availableJobs[index]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.map_outlined, color: AppColors.primaryGreen, size: 36),
          ),
          Spacing.gap16,
          const Text('No jobs available', style: TextStyle(
            fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          )),
          Spacing.gap8,
          const Text('Check back soon for new pickup requests', style: TextStyle(
            fontFamily: 'Inter', fontSize: 13, color: AppColors.textTertiary,
          )),
        ],
      ),
    );
  }

  Widget _buildJobCard(dynamic job) {
    final wasteType = job['waste_type'] ?? job['category'] ?? 'Mixed';
    final weight = job['estimated_weight'] ?? job['weight'] ?? '—';
    final address = job['address'] ?? 'Unknown location';
    final id = job['id'] ?? '';

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
          // Waste type + weight
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.recycling_rounded, color: AppColors.primaryGreen, size: 22),
              ),
              Spacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(wasteType, style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    )),
                    const SizedBox(height: 2),
                    Text('$weight kg estimated', style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary,
                    )),
                  ],
                ),
              ),
              // Earnings estimate
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '₦${((weight is num ? weight : double.tryParse(weight.toString()) ?? 5) * 50).toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          Spacing.gap12,

          // Address
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.textTertiary, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(address, style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 13, color: AppColors.textSecondary,
                ), maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),

          // Notes if any
          if (job['notes'] != null && job['notes'].toString().isNotEmpty) ...[
            Spacing.gap8,
            Text(
              'Note: ${job['notes']}',
              style: const TextStyle(
                fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
          ],

          Spacing.gap16,

          // Accept button
          GestureDetector(
            onTap: () => _acceptJob(id.toString()),
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('Accept Job', style: TextStyle(
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
}
