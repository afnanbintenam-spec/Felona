import 'package:flutter/material.dart';
import 'package:felo_na/core/constants/app_colors.dart';

/// Stats card widget for displaying metrics.
///
/// Features:
/// - Gradient background
/// - Icon, number, and label
/// - Customizable colors
/// - Tap action support
class StatsCard extends StatelessWidget {
  final String number;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final double? width;

  const StatsCard({
    super.key,
    required this.number,
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 140,
        height: 100,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            // Number and Label
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gray700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
