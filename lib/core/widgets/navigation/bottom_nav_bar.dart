import 'package:flutter/material.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/enums.dart';

/// Bottom navigation bar component with role-specific items.
///
/// Features:
/// - Role-specific navigation items
/// - Active/inactive states
/// - Smooth transitions
/// - Badge support for notifications
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final UserRole userRole;
  final int? notificationCount;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.userRole,
    this.notificationCount,
  });

  Color _getRoleColor() {
    switch (userRole) {
      case UserRole.normalUser:
        return AppColors.primary500;
      case UserRole.buyer:
        return AppColors.accent500;
      case UserRole.collector:
        return AppColors.secondary500;
    }
  }

  List<BottomNavItem> _getNavItems() {
    switch (userRole) {
      case UserRole.normalUser:
        return [
          BottomNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
          ),
          BottomNavItem(
            icon: Icons.store_outlined,
            activeIcon: Icons.store,
            label: 'Marketplace',
          ),
          BottomNavItem(
            icon: Icons.local_shipping_outlined,
            activeIcon: Icons.local_shipping,
            label: 'Pickups',
          ),
          BottomNavItem(
            icon: Icons.eco_outlined,
            activeIcon: Icons.eco,
            label: 'Eco Score',
          ),
          BottomNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
          ),
        ];

      case UserRole.buyer:
        return [
          BottomNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
          ),
          BottomNavItem(
            icon: Icons.search_outlined,
            activeIcon: Icons.search,
            label: 'Search',
          ),
          BottomNavItem(
            icon: Icons.shopping_bag_outlined,
            activeIcon: Icons.shopping_bag,
            label: 'My Offers',
          ),
          BottomNavItem(
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
            label: 'Messages',
          ),
          BottomNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
          ),
        ];

      case UserRole.collector:
        return [
          BottomNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
          ),
          BottomNavItem(
            icon: Icons.map_outlined,
            activeIcon: Icons.map,
            label: 'Jobs',
          ),
          BottomNavItem(
            icon: Icons.history_outlined,
            activeIcon: Icons.history,
            label: 'History',
          ),
          BottomNavItem(
            icon: Icons.account_balance_wallet_outlined,
            activeIcon: Icons.account_balance_wallet,
            label: 'Earnings',
          ),
          BottomNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _getNavItems();
    final roleColor = _getRoleColor();

    return Container(
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
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _buildNavItem(
                item: items[index],
                isActive: currentIndex == index,
                roleColor: roleColor,
                onTap: () => onTap(index),
                showBadge: index == 3 && notificationCount != null && notificationCount! > 0,
                badgeCount: notificationCount,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BottomNavItem item,
    required bool isActive,
    required Color roleColor,
    required VoidCallback onTap,
    bool showBadge = false,
    int? badgeCount,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? item.activeIcon : item.icon,
                  color: isActive ? roleColor : AppColors.gray500,
                  size: 24,
                ),
                if (showBadge && badgeCount != null)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : badgeCount.toString(),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // Label
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? roleColor : AppColors.gray500,
              ),
            ),
            const SizedBox(height: 2),
            // Active indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: isActive ? 24 : 0,
              decoration: BoxDecoration(
                color: roleColor,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom navigation item model.
class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
