import 'package:flutter/material.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/enums.dart';

/// Status badge widget for displaying status.
///
/// Features:
/// - Color-coded by status
/// - Rounded pill shape
/// - Compact design
class StatusBadge extends StatelessWidget {
  final String text;
  final Color? color;

  const StatusBadge({
    super.key,
    required this.text,
    this.color,
  });

  /// Factory constructor for pickup status.
  factory StatusBadge.pickup(PickupStatus status) {
    Color color;
    switch (status) {
      case PickupStatus.pending:
        color = AppColors.warning;
        break;
      case PickupStatus.assigned:
        color = const Color(0xFF9B59B6);
        break;
      case PickupStatus.accepted:
      case PickupStatus.onTheWay:
        color = AppColors.info;
        break;
      case PickupStatus.arrived:
        color = AppColors.success;
        break;
      case PickupStatus.completed:
        color = AppColors.success;
        break;
      case PickupStatus.cancelled:
        color = AppColors.error;
        break;
    }

    return StatusBadge(
      text: status.displayName,
      color: color,
    );
  }

  /// Factory constructor for listing status.
  factory StatusBadge.listing(ListingStatus status) {
    Color color;
    switch (status) {
      case ListingStatus.active:
        color = AppColors.primary500;
        break;
      case ListingStatus.sold:
        color = AppColors.success;
        break;
      case ListingStatus.inactive:
        color = AppColors.gray500;
        break;
    }

    return StatusBadge(
      text: status.displayName,
      color: color,
    );
  }

  /// Factory constructor for offer status.
  factory StatusBadge.offer(OfferStatus status) {
    Color color;
    switch (status) {
      case OfferStatus.pending:
        color = AppColors.warning;
        break;
      case OfferStatus.accepted:
        color = AppColors.success;
        break;
      case OfferStatus.rejected:
        color = AppColors.error;
        break;
      case OfferStatus.expired:
        color = AppColors.gray500;
        break;
    }

    return StatusBadge(
      text: status.displayName,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppColors.primary500;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }
}
