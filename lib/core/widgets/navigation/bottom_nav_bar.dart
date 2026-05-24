import 'package:flutter/material.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/enums.dart';

/// Floating Bottom Nav — Dark Teal Premium
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final UserRole userRole;
  final int? notificationCount;

  const AppBottomNavBar({
    super.key, required this.currentIndex, required this.onTap,
    required this.userRole, this.notificationCount,
  });

  List<_NavItem> _getNavItems() {
    switch (userRole) {
      case UserRole.normalUser:
        return [
          _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
          _NavItem(Icons.store_outlined, Icons.store_rounded, 'Market'),
          _NavItem(Icons.local_shipping_outlined, Icons.local_shipping_rounded, 'Pickups'),
          _NavItem(Icons.eco_outlined, Icons.eco_rounded, 'Eco'),
          _NavItem(Icons.person_outline, Icons.person_rounded, 'Profile'),
        ];
      case UserRole.buyer:
        return [
          _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
          _NavItem(Icons.search_outlined, Icons.search_rounded, 'Search'),
          _NavItem(Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'Offers'),
          _NavItem(Icons.chat_bubble_outline, Icons.chat_bubble_rounded, 'Chat'),
          _NavItem(Icons.person_outline, Icons.person_rounded, 'Profile'),
        ];
      case UserRole.collector:
        return [
          _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
          _NavItem(Icons.map_outlined, Icons.map_rounded, 'Jobs'),
          _NavItem(Icons.history_outlined, Icons.history_rounded, 'History'),
          _NavItem(Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, 'Earn'),
          _NavItem(Icons.person_outline, Icons.person_rounded, 'Profile'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _getNavItems();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      color: Colors.transparent,
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16, offset: const Offset(0, 4),
          )],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (i) =>
            _buildItem(items[i], i == currentIndex, () => onTap(i)),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(_NavItem item, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? item.activeIcon : item.icon,
              color: active ? AppColors.primaryGreen : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(item.label, style: TextStyle(
              fontFamily: 'Inter', fontSize: 10,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? AppColors.primaryGreen : AppColors.textMuted,
            )),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon, activeIcon;
  final String label;
  _NavItem(this.icon, this.activeIcon, this.label);
}
