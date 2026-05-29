import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/features/pickup/domain/entities/pickup_request.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_bloc.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_event.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_state.dart';

/// Pickup Detail Screen — Shows full pickup info, status timeline,
/// collector info, and action buttons.
class PickupDetailScreen extends StatefulWidget {
  final String? pickupId;

  const PickupDetailScreen({super.key, this.pickupId});

  @override
  State<PickupDetailScreen> createState() => _PickupDetailScreenState();
}

class _PickupDetailScreenState extends State<PickupDetailScreen> {
  PickupRequest? _pickup;

  @override
  void initState() {
    super.initState();
    if (widget.pickupId != null) {
      context
          .read<PickupBloc>()
          .add(LoadPickupDetailRequested(pickupId: widget.pickupId!));
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
          'Pickup Details',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (_pickup != null &&
              _pickup!.status != PickupStatus.completed &&
              _pickup!.status != PickupStatus.cancelled)
            IconButton(
              icon: const Icon(Icons.location_on_rounded,
                  color: AppColors.primaryGreen),
              onPressed: () {
                Navigator.pushNamed(context, '/pickup-tracking',
                    arguments: {'pickupId': _pickup!.id});
              },
            ),
        ],
      ),
      body: BlocConsumer<PickupBloc, PickupState>(
        listener: (context, state) {
          if (state is PickupDetailLoaded) {
            setState(() => _pickup = state.pickup);
          } else if (state is PickupStatusUpdated) {
            setState(() => _pickup = state.pickup);
          }
        },
        builder: (context, state) {
          if (_pickup == null && state is PickupLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (_pickup == null) {
            return const Center(
              child: Text(
                'Pickup not found',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.textTertiary,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Timeline
                _buildStatusTimeline(),
                const SizedBox(height: 20),

                // Details Card
                _buildDetailsCard(),
                const SizedBox(height: 16),

                // Schedule Info
                if (_pickup!.scheduledDate != null) _buildScheduleCard(),
                if (_pickup!.scheduledDate != null) const SizedBox(height: 16),

                // Collector Info
                if (_pickup!.collectorName != null) _buildCollectorCard(),
                if (_pickup!.collectorName != null) const SizedBox(height: 16),

                // Action Buttons
                _buildActionButtons(),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusTimeline() {
    final statuses = [
      PickupStatus.pending,
      PickupStatus.assigned,
      PickupStatus.onTheWay,
      PickupStatus.arrived,
      PickupStatus.completed,
    ];

    final currentIndex =
        statuses.indexOf(_pickup!.status).clamp(0, statuses.length - 1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(statuses.length, (index) {
            final status = statuses[index];
            final isCompleted = index < currentIndex;
            final isActive = index == currentIndex;
            final isLast = index == statuses.length - 1;

            return _buildTimelineStep(
              title: status.displayName,
              isCompleted: isCompleted,
              isActive: isActive,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required bool isCompleted,
    required bool isActive,
    required bool isLast,
  }) {
    final color = isCompleted || isActive
        ? AppColors.primaryGreen
        : AppColors.textMuted;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.primaryGreen : null,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 12)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isCompleted
                          ? AppColors.primaryGreen.withValues(alpha: 0.5)
                          : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isCompleted || isActive
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pickup Details',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _detailRow(Icons.category_rounded, 'Category',
              _pickup!.category.displayName),
          _detailRow(Icons.scale_rounded, 'Weight',
              '${_pickup!.estimatedWeight} kg'),
          _detailRow(
              Icons.location_on_rounded, 'Address', _pickup!.address),
          _detailRow(Icons.calendar_today_rounded, 'Created',
              DateFormat('MMM d, yyyy').format(_pickup!.createdAt)),
          if (_pickup!.notes != null && _pickup!.notes!.isNotEmpty)
            _detailRow(Icons.note_rounded, 'Notes', _pickup!.notes!),
          if (_pickup!.ecoPointsEarned != null)
            _detailRow(Icons.eco_rounded, 'Eco Points',
                '+${_pickup!.ecoPointsEarned}'),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Scheduled',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (_pickup!.isRecurring) ...[
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Recurring',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _detailRow(Icons.event_rounded, 'Date',
              DateFormat('EEEE, MMM d').format(_pickup!.scheduledDate!)),
          if (_pickup!.timeSlot != null)
            _detailRow(Icons.access_time_rounded, 'Time',
                _pickup!.timeSlot!.displayName),
          if (_pickup!.isRecurring && _pickup!.recurrenceFrequency != null)
            _detailRow(Icons.repeat_rounded, 'Frequency',
                _pickup!.recurrenceFrequency!.displayName),
        ],
      ),
    );
  }

  Widget _buildCollectorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Collector',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded,
                    color: AppColors.primaryGreen, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _pickup!.collectorName!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (_pickup!.collectorRating != null)
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            _pickup!.collectorRating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (_pickup!.collectorPhone != null)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.phone_rounded,
                      color: AppColors.primaryGreen, size: 18),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final status = _pickup!.status;

    if (status == PickupStatus.completed && _pickup!.rating == null) {
      return _actionButton(
        'Rate this Pickup ⭐',
        AppColors.primaryGreen,
        () => Navigator.pushNamed(context, '/rate-pickup',
            arguments: {'pickupId': _pickup!.id}),
      );
    }

    if (status == PickupStatus.onTheWay ||
        status == PickupStatus.assigned ||
        status == PickupStatus.accepted) {
      return _actionButton(
        'Track Live 📍',
        AppColors.primaryGreen,
        () => Navigator.pushNamed(context, '/pickup-tracking',
            arguments: {'pickupId': _pickup!.id}),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _actionButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textTertiary, size: 18),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
