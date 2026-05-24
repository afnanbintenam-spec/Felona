import 'package:flutter/material.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/spacing.dart';

/// A single step in the pickup timeline.
class PickupTimelineStep {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? timestamp;
  final bool isCompleted;
  final bool isActive;

  const PickupTimelineStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.timestamp,
    this.isCompleted = false,
    this.isActive = false,
  });
}

/// Vertical timeline showing pickup progress.
///
/// Steps: Requested → Accepted → On the Way → Collected → Recycled
/// - Completed steps show a green checkmark
/// - Active step pulses/glows
/// - Future steps are muted
class PickupTimeline extends StatelessWidget {
  final List<PickupTimelineStep> steps;

  const PickupTimeline({super.key, required this.steps});

  /// Convenience factory with default pickup steps
  factory PickupTimeline.defaultSteps({
    int completedCount = 0,
    int activeIndex = 0,
    List<String?> timestamps = const [],
  }) {
    final defaultSteps = [
      const _DefaultStep(Icons.send_rounded, 'Requested', 'Pickup request submitted'),
      const _DefaultStep(Icons.check_circle_outline_rounded, 'Accepted', 'Driver assigned'),
      const _DefaultStep(Icons.local_shipping_rounded, 'On the Way', 'Driver en route'),
      const _DefaultStep(Icons.inventory_rounded, 'Collected', 'Items picked up'),
      const _DefaultStep(Icons.recycling_rounded, 'Recycled', 'Processed & recycled'),
    ];

    return PickupTimeline(
      steps: List.generate(defaultSteps.length, (i) {
        return PickupTimelineStep(
          icon: defaultSteps[i].icon,
          title: defaultSteps[i].title,
          subtitle: defaultSteps[i].subtitle,
          timestamp: i < timestamps.length ? timestamps[i] : null,
          isCompleted: i < completedCount,
          isActive: i == activeIndex,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Spacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pickup Progress',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Spacing.gap16,
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isLast = index == steps.length - 1;
            return _TimelineStepWidget(
              step: step,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineStepWidget extends StatefulWidget {
  final PickupTimelineStep step;
  final bool isLast;

  const _TimelineStepWidget({
    required this.step,
    required this.isLast,
  });

  @override
  State<_TimelineStepWidget> createState() => _TimelineStepWidgetState();
}

class _TimelineStepWidgetState extends State<_TimelineStepWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.step.isActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final color = step.isCompleted
        ? AppColors.primaryGreen
        : step.isActive
            ? AppColors.primaryGreen
            : AppColors.textMuted;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column (dot + line)
          SizedBox(
            width: 32,
            child: Column(
              children: [
                // Dot / checkmark
                _buildDot(step, color),
                // Connector line
                if (!widget.isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: step.isCompleted
                          ? AppColors.primaryGreen.withValues(alpha: 0.5)
                          : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          Spacing.hGap12,
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: widget.isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: step.isCompleted || step.isActive
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: step.isCompleted || step.isActive
                          ? AppColors.textSecondary
                          : AppColors.textMuted,
                    ),
                  ),
                  if (step.timestamp != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      step.timestamp!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(PickupTimelineStep step, Color color) {
    if (step.isCompleted) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
      );
    }

    if (step.isActive) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen
                      .withValues(alpha: 0.3 * _pulseAnimation.value),
                  blurRadius: 8 * _pulseAnimation.value,
                  spreadRadius: 2 * _pulseAnimation.value,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      );
    }

    // Future step — muted
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: Center(
        child: Icon(step.icon, color: AppColors.textMuted, size: 12),
      ),
    );
  }
}

/// Internal helper for default step data
class _DefaultStep {
  final IconData icon;
  final String title;
  final String subtitle;
  const _DefaultStep(this.icon, this.title, this.subtitle);
}
