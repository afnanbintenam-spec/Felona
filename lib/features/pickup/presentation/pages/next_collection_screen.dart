import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_bloc.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_event.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_state.dart';
import 'package:felo_na/features/pickup/domain/entities/pickup_request.dart';

/// Pickups Page — User-friendly pickup request list with status tracking.
///
/// Shows all user's pickup requests with clear status indicators
/// (pending, accepted, rejected, completed).
class NextCollectionScreen extends StatefulWidget {
  const NextCollectionScreen({super.key});

  @override
  State<NextCollectionScreen> createState() => _NextCollectionScreenState();
}

class _NextCollectionScreenState extends State<NextCollectionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PickupBloc>().add(const LoadPickupsRequested());
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
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  const Text(
                    'My Pickups',
                    style: TextStyle(
                      fontFamily: 'Finlandica',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      context
                          .read<PickupBloc>()
                          .add(const LoadPickupsRequested());
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.border, width: 1),
                      ),
                      child: const Icon(Icons.refresh_rounded,
                          color: AppColors.textSecondary, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Request a waste pickup and track its status',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Content
            Expanded(
              child: BlocBuilder<PickupBloc, PickupState>(
                builder: (context, state) {
                  if (state is PickupLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    );
                  } else if (state is PickupError) {
                    return _buildErrorState(state.message);
                  } else if (state is PickupLoaded) {
                    if (state.pickups.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildPickupList(state.pickups);
                  }
                  return _buildEmptyState();
                },
              ),
            ),
          ],
        ),
      ),
      // FAB to create new pickup
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/create-pickup');
          if (mounted) {
            context.read<PickupBloc>().add(const LoadPickupsRequested());
          }
        },
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Request Pickup',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                size: 48,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Pickup Requests Yet',
              style: TextStyle(
                fontFamily: 'Finlandica',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the button below to request your first\nwaste pickup. A collector will pick it up!',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                context
                    .read<PickupBloc>()
                    .add(const LoadPickupsRequested());
              },
              child: const Text(
                'Retry',
                style: TextStyle(color: AppColors.primaryGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupList(List<PickupRequest> pickups) {
    // Sort: pending first, then by date
    final sorted = List<PickupRequest>.from(pickups)
      ..sort((a, b) {
        final statusOrder = _statusPriority(a.status)
            .compareTo(_statusPriority(b.status));
        if (statusOrder != 0) return statusOrder;
        return b.createdAt.compareTo(a.createdAt);
      });

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: () async {
        context.read<PickupBloc>().add(const LoadPickupsRequested());
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: sorted.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildPickupCard(sorted[index]);
        },
      ),
    );
  }

  int _statusPriority(PickupStatus status) {
    switch (status) {
      case PickupStatus.pending:
        return 0;
      case PickupStatus.accepted:
        return 1;
      case PickupStatus.onTheWay:
        return 2;
      case PickupStatus.arrived:
        return 3;
      case PickupStatus.completed:
        return 4;
      case PickupStatus.cancelled:
        return 5;
      default:
        return 3;
    }
  }

  Widget _buildPickupCard(PickupRequest pickup) {
    final statusColor = _getStatusColor(pickup.status);
    final statusIcon = _getStatusIcon(pickup.status);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/pickup-detail', arguments: pickup.id);
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
            // Top row: Category + Status badge
            Row(
              children: [
                // Category icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(pickup.category)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(pickup.category),
                    color: _getCategoryColor(pickup.category),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Category name + date
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
                      Text(
                        _formatDate(pickup.createdAt),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        pickup.status.displayName,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Details row
            Row(
              children: [
                _buildDetailChip(
                    Icons.scale_rounded, '${pickup.estimatedWeight} kg'),
                const SizedBox(width: 12),
                if (pickup.totalPrice != null)
                  _buildDetailChip(
                      Icons.payments_rounded, '৳${pickup.totalPrice!.toStringAsFixed(0)}'),
                if (pickup.totalPrice != null)
                  const SizedBox(width: 12),
                if (pickup.timeSlot != null)
                  _buildDetailChip(
                      Icons.access_time_rounded, pickup.timeSlot!.displayName),
              ],
            ),

            // Collector info (if accepted)
            if (pickup.status == PickupStatus.accepted ||
                pickup.status == PickupStatus.onTheWay ||
                pickup.status == PickupStatus.arrived) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_rounded,
                        size: 18, color: AppColors.primaryGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Collector: ${pickup.collectorName ?? 'Assigned'}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (pickup.collectorPhone != null)
                      GestureDetector(
                        onTap: () {
                          // Could launch phone dialer
                        },
                        child: const Icon(Icons.phone_rounded,
                            size: 18, color: AppColors.primaryGreen),
                      ),
                  ],
                ),
              ),
            ],

            // Cancelled/Rejected message
            if (pickup.status == PickupStatus.cancelled) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cancel_rounded,
                        size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This pickup was cancelled',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(PickupStatus status) {
    switch (status) {
      case PickupStatus.pending:
        return const Color(0xFFF39C12);
      case PickupStatus.accepted:
      case PickupStatus.assigned:
        return const Color(0xFF03A9F4);
      case PickupStatus.onTheWay:
        return const Color(0xFF9B59B6);
      case PickupStatus.arrived:
        return const Color(0xFF2ECC71);
      case PickupStatus.completed:
        return const Color(0xFF27AE60);
      case PickupStatus.cancelled:
        return const Color(0xFFE74C3C);
    }
  }

  IconData _getStatusIcon(PickupStatus status) {
    switch (status) {
      case PickupStatus.pending:
        return Icons.hourglass_top_rounded;
      case PickupStatus.accepted:
      case PickupStatus.assigned:
        return Icons.check_circle_outline_rounded;
      case PickupStatus.onTheWay:
        return Icons.local_shipping_rounded;
      case PickupStatus.arrived:
        return Icons.place_rounded;
      case PickupStatus.completed:
        return Icons.task_alt_rounded;
      case PickupStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  Color _getCategoryColor(WasteCategory category) {
    return Color(int.parse(category.colorHex.replaceFirst('#', '0xFF')));
  }

  IconData _getCategoryIcon(WasteCategory category) {
    switch (category) {
      case WasteCategory.plastic:
        return Icons.water_drop_rounded;
      case WasteCategory.metal:
        return Icons.hardware_rounded;
      case WasteCategory.paper:
        return Icons.description_rounded;
      case WasteCategory.glass:
        return Icons.local_bar_rounded;
      case WasteCategory.electronics:
        return Icons.devices_rounded;
      case WasteCategory.other:
        return Icons.inventory_2_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
