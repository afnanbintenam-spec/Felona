import 'package:flutter/material.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/app_text_styles.dart';
import 'package:felo_na/core/widgets/navigation/custom_app_bar.dart';
import 'package:felo_na/core/widgets/chips/category_chip.dart';
import 'package:felo_na/core/widgets/buttons/primary_button.dart';
import 'package:felo_na/core/widgets/buttons/secondary_button.dart';

enum PickupStatus { pending, accepted, onTheWay, completed }

class PickupDetailScreen extends StatefulWidget {
  final String? pickupId;

  const PickupDetailScreen({super.key, this.pickupId});

  @override
  State<PickupDetailScreen> createState() => _PickupDetailScreenState();
}

class _PickupDetailScreenState extends State<PickupDetailScreen> {
  // Mock data
  PickupStatus _currentStatus = PickupStatus.accepted;
  final String _wasteCategory = 'Plastic';
  final double _weight = 15.5;
  final String _address = '123 Main Street, Apt 4B, New York, NY 10001';
  final String _createdDate = 'Jan 15, 2024';
  final String? _collectorName = 'Mike Wilson';
  final String? _collectorPhone = '+1 (555) 123-4567';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pickup Details',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Status Timeline
            _buildStatusTimeline(),
            const SizedBox(height: 24),
            // Details Card
            _buildDetailsCard(),
            const SizedBox(height: 16),
            // Collector Info Card (if assigned)
            if (_collectorName != null) _buildCollectorCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildStatusTimeline() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            'Status',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 24),
          _buildTimelineStep(
            title: 'Pending',
            subtitle: 'Waiting for collector',
            status: PickupStatus.pending,
            isFirst: true,
          ),
          _buildTimelineStep(
            title: 'Accepted',
            subtitle: 'Collector assigned',
            status: PickupStatus.accepted,
          ),
          _buildTimelineStep(
            title: 'On The Way',
            subtitle: 'Collector is coming',
            status: PickupStatus.onTheWay,
          ),
          _buildTimelineStep(
            title: 'Completed',
            subtitle: 'Pickup finished',
            status: PickupStatus.completed,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required PickupStatus status,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final isCompleted = status.index <= _currentStatus.index;
    final isActive = status == _currentStatus;
    final color = isCompleted ? AppColors.primary500 : AppColors.gray300;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 20,
                color: isCompleted ? AppColors.primary500 : AppColors.gray300,
              ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primary500 : AppColors.white,
                border: Border.all(
                  color: color,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.white,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 20,
                color: isCompleted && !isActive
                    ? AppColors.primary500
                    : AppColors.gray300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Text
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isCompleted ? AppColors.primary500 : AppColors.gray700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            'Pickup Details',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 16),
          // Waste Category
          Row(
            children: [
              const Icon(
                Icons.category_outlined,
                size: 20,
                color: AppColors.gray700,
              ),
              const SizedBox(width: 12),
              Text(
                'Category:',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray700,
                ),
              ),
              const SizedBox(width: 8),
              CategoryChip(
                label: _wasteCategory,
                isSelected: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Weight
          Row(
            children: [
              const Icon(
                Icons.scale_outlined,
                size: 20,
                color: AppColors.gray700,
              ),
              const SizedBox(width: 12),
              Text(
                'Weight:',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$_weight kg',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 20,
                color: AppColors.gray700,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pickup Address:',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.gray700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _address,
                      style: AppTextStyles.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Created Date
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: AppColors.gray700,
              ),
              const SizedBox(width: 12),
              Text(
                'Created:',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _createdDate,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollectorCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            'Collector Information',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.gray200,
                child: const Icon(
                  Icons.person,
                  size: 32,
                  color: AppColors.gray500,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _collectorName!,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _collectorPhone!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.gray700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: 'Call',
                  icon: Icons.phone_outlined,
                  onPressed: () {
                    // TODO: Implement call functionality
                  },
                  height: 44,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SecondaryButton(
                  text: 'Message',
                  icon: Icons.message_outlined,
                  onPressed: () {
                    // TODO: Implement message functionality
                  },
                  height: 44,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget? _buildBottomBar() {
    // Only show action button for collector role
    if (_currentStatus == PickupStatus.accepted) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: PrimaryButton(
            text: 'Mark as On The Way',
            onPressed: () {
              setState(() {
                _currentStatus = PickupStatus.onTheWay;
              });
            },
          ),
        ),
      );
    } else if (_currentStatus == PickupStatus.onTheWay) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: PrimaryButton(
            text: 'Mark as Completed',
            onPressed: () {
              setState(() {
                _currentStatus = PickupStatus.completed;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pickup completed! Eco points earned.'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ),
      );
    }
    return null;
  }
}
