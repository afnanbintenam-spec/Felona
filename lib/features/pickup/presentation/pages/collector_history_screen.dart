import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/spacing.dart';
import 'package:felo_na/core/network/api_client.dart';

/// Collector History Screen — Completed/cancelled job history
class CollectorHistoryScreen extends StatefulWidget {
  const CollectorHistoryScreen({super.key});

  @override
  State<CollectorHistoryScreen> createState() => _CollectorHistoryScreenState();
}

class _CollectorHistoryScreenState extends State<CollectorHistoryScreen> {
  final _dio = Dio(BaseOptions(
    baseUrl: ApiClient.baseUrl,
    headers: {'Content-Type': 'application/json'},
  ));
  final _storage = const FlutterSecureStorage();

  List<dynamic> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final response = await _dio.get('/pickups/history');
      if (response.statusCode == 200) {
        _history = response.data['pickups'] ?? [];
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
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
                  const Text('Job History', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
                  Spacing.gap8,
                  Text(
                    '${_history.length} completed jobs',
                    style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 14, color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Spacing.gap16,

            // History list
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                  : _history.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadHistory,
                          color: AppColors.primaryGreen,
                          backgroundColor: AppColors.card,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _history.length,
                            separatorBuilder: (_, __) => Spacing.gap8,
                            itemBuilder: (context, index) =>
                                _buildHistoryCard(_history[index]),
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
            child: const Icon(Icons.history_rounded, color: AppColors.primaryGreen, size: 36),
          ),
          Spacing.gap16,
          const Text('No history yet', style: TextStyle(
            fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          )),
          Spacing.gap8,
          const Text('Completed jobs will appear here', style: TextStyle(
            fontFamily: 'Inter', fontSize: 13, color: AppColors.textTertiary,
          )),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(dynamic job) {
    final status = job['status'] ?? 'completed';
    final isCompleted = status == 'completed';
    final statusColor = isCompleted ? AppColors.success : AppColors.error;
    final statusIcon = isCompleted ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
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
                  job['address'] ?? job['location'] ?? 'Pickup',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${job['waste_type'] ?? job['category'] ?? 'Mixed'} • ${job['weight'] ?? job['estimated_weight'] ?? '—'}kg',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isCompleted ? '₦${job['earnings'] ?? job['price'] ?? '0'}' : 'Cancelled',
                style: TextStyle(
                  fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600,
                  color: isCompleted ? AppColors.primaryGreen : AppColors.error,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(job['completed_at'] ?? job['updated_at'] ?? ''),
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
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inDays == 0) return 'Today';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }
}
