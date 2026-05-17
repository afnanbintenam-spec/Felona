import 'package:flutter/material.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/enums.dart';

/// Role selection card for registration screen.
///
/// Features:
/// - Visual selection state
/// - Role icon, title, and description
/// - Radio button indicator
/// - Tap animation
class RoleSelectionCard extends StatelessWidget {
  final UserRole role;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleSelectionCard({
    super.key,
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getRoleIcon() {
    switch (role) {
      case UserRole.normalUser:
        return Icons.eco;
      case UserRole.buyer:
        return Icons.shopping_bag;
      case UserRole.collector:
        return Icons.local_shipping;
    }
  }

  Color _getRoleColor() {
    switch (role) {
      case UserRole.normalUser:
        return AppColors.primary500;
      case UserRole.buyer:
        return AppColors.accent500;
      case UserRole.collector:
        return AppColors.secondary500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? _getRoleColor().withOpacity(0.05) : AppColors.white,
          border: Border.all(
            color: isSelected ? _getRoleColor() : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Role Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getRoleColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getRoleIcon(),
                color: _getRoleColor(),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Title and Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    role.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? _getRoleColor() : AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray700,
                    ),
                  ),
                ],
              ),
            ),
            // Radio Indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _getRoleColor() : AppColors.gray300,
                  width: 2,
                ),
                color: isSelected ? _getRoleColor() : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
