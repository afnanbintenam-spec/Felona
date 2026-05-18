import 'package:flutter/material.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/enums.dart';

/// Floating Bottom Navigation Bar — Pixel-perfect dark theme
/// Dark background, green active state, labels always visible
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

  List<_NavItem> _getNavItems() {
    switch (userRole) {
      case UserRole.normalUser:
        return [
          _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
          _NavItem(icon: Icons.store_outlined, activeIcon: Icons.store_rounded, label: 'Marketplace'),
          _NavItem(icon: Icons.local_shipping_outlined, activeIcon: Icons.local_shipping_rounded, label: 'Pickups'),
          _NavItem(icon: Icons.eco_outlined, activeIcon: Icons.eco_rounded, label: 'Eco Score'),
          _NavItem(icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Profile'),
        ];
      case UserRole.buyer:
        return [
          _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
          _NavItem(icon: Icons.search_outlined, activeIcon: Icons.search_rounded, label: 'Search'),
          _NavItem(icon: Icons.shopping_bag_outlined, activeIcon: Icons.shopping_bag_rounded, label: 'Offers'),
          _NavItem(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble_rounded, label: 'Chat'),
          _NavItem(icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Profile'),
        ];
      case UserRole.collector:
        return [
          _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
          _NavItem(icon: Icons.map_outlined, activeIcon: Icons.map_rounded, label: 'Jobs'),
          _NavItem(icon: Icons.history_outlined, activeIcon: Icons.history_rounded, label: 'History'),
          _NavItem(icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet_rounded, label: 'Earn'),
          _NavItem(icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Profile'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _getNavItems();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      color: Colors.transparent,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF1E1E1E),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            items.length,
            (index) => _buildNavIcon(
              item: items[index],
              isActive: currentIndex == index,
              onTap: () => onTap(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon({
    required _NavItem item,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? item.activeIcon : item.icon,
              color: isActive
                  ? AppColors.accentGreen
                  : Colors.white.withValues(alpha: 0.4),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? AppColors.accentGreen
                    : Colors.white.withValues(alpha: 0.4),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
