import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/features/pickup/domain/entities/pickup_request.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_bloc.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_event.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_state.dart';

/// Pickup History Screen — Paginated list of past pickups.
class PickupHistoryScreen extends StatefulWidget {
  const PickupHistoryScreen({super.key});

  @override
  State<PickupHistoryScreen> createState() => _PickupHistoryScreenState();
}

class _PickupHistoryScreenState extends State<PickupHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<PickupRequest> _pickups = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadHistory() {
    context
        .read<PickupBloc>()
        .add(LoadPickupHistoryRequested(page: _currentPage));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        _hasMore &&
        !_isLoadingMore) {
      _isLoadingMore = true;
      _currentPage++;
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pickup History',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocConsumer<PickupBloc, PickupState>(
        listener: (context, state) {
          if (state is PickupHistoryLoaded) {
            setState(() {
              if (_currentPage == 1) {
                _pickups.clear();
              }
              _pickups.addAll(state.pickups);
              _hasMore = state.hasMore;
              _isLoadingMore = false;
            });
          }
        },
        builder: (context, state) {
          if (_pickups.isEmpty && state is PickupLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (_pickups.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              _currentPage = 1;
              _loadHistory();
            },
            color: AppColors.primaryGreen,
            backgroundColor: AppColors.card,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _pickups.length + (_hasMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == _pickups.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                          color: AppColors.primaryGreen, strokeWidth: 2),
                    ),
                  );
                }
                return _buildHistoryCard(_pickups[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history_rounded,
                color: AppColors.primaryGreen, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'No pickup history',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your completed pickups will appear here',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(PickupRequest pickup) {
    final statusColor = _getStatusColor(pickup.status);
    final dateStr = DateFormat('MMM d, yyyy').format(pickup.createdAt);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/pickup-tracking',
            arguments: {'pickupId': pickup.id});
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getStatusIcon(pickup.status),
                    color: statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pickup.category.displayName,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${pickup.estimatedWeight}kg • $dateStr',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    pickup.status.displayName,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Address
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: AppColors.textTertiary, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    pickup.address,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Eco points
            if (pickup.ecoPointsEarned != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.eco_rounded,
                      color: AppColors.primaryGreen, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '+${pickup.ecoPointsEarned} eco points',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ],

            // Rating
            if (pickup.rating != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  ...List.generate(5, (i) {
                    return Icon(
                      i < pickup.rating!.round()
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                  const SizedBox(width: 6),
                  Text(
                    pickup.rating!.toStringAsFixed(1),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],

            // Rate button for completed unrated pickups
            if (pickup.status == PickupStatus.completed &&
                pickup.rating == null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/rate-pickup',
                      arguments: {'pickupId': pickup.id});
                },
                child: Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color:
                            AppColors.primaryGreen.withValues(alpha: 0.3)),
                  ),
                  child: const Center(
                    child: Text(
                      'Rate this pickup ⭐',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(PickupStatus status) {
    switch (status) {
      case PickupStatus.completed:
        return AppColors.success;
      case PickupStatus.cancelled:
        return AppColors.error;
      case PickupStatus.onTheWay:
      case PickupStatus.accepted:
      case PickupStatus.assigned:
        return AppColors.info;
      default:
        return AppColors.warning;
    }
  }

  IconData _getStatusIcon(PickupStatus status) {
    switch (status) {
      case PickupStatus.completed:
        return Icons.check_circle_rounded;
      case PickupStatus.cancelled:
        return Icons.cancel_rounded;
      case PickupStatus.onTheWay:
        return Icons.local_shipping_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }
}
