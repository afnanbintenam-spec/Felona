import 'package:flutter/material.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/app_text_styles.dart';

class SortingGuideScreen extends StatelessWidget {
  const SortingGuideScreen({super.key});

  void _showCategoryDetail(BuildContext context, String icon, String label) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Text(label, style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.gray900,
                )),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _getCategoryDescription(label),
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.gray700,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _getCategoryDescription(String category) {
    switch (category.toLowerCase()) {
      case 'glass':
        return 'Rinse glass bottles and jars before recycling. Remove lids and caps. Do not recycle broken glass, mirrors, or window panes in the recycling bin.';
      case 'food waste':
        return 'Compost food scraps like fruit peels, vegetable trimmings, and coffee grounds. Keep it separate from regular recyclables to avoid contamination.';
      case 'batteries':
        return 'Never throw batteries in regular trash. Take them to designated collection points. They contain hazardous materials that can leach into soil and water.';
      case 'paper-cardboard':
        return 'Flatten cardboard boxes to save space. Keep paper dry — wet or greasy paper (like pizza boxes) cannot be recycled. Remove any plastic tape or staples if possible.';
      case 'electronics':
        return 'E-waste must be handled by certified recyclers. Never burn electronics. Donate working devices. Many manufacturers offer take-back programs.';
      case 'green waste':
        return 'Garden clippings, leaves, and branches go in green waste bins. Avoid mixing with food waste. This material is composted into soil amendment.';
      case 'medication':
        return 'Return unused medication to pharmacies for proper disposal. Never flush medicines down the toilet — they contaminate water supplies.';
      case 'hazardous waste':
        return 'Paints, solvents, pesticides, and cleaning chemicals need special handling. Take them to hazardous waste collection centers, never to regular bins.';
      case 'bulky waste':
        return 'Large items like furniture and appliances require scheduled collection. Contact your local waste management service for bulk pickup arrangements.';
      default:
        return 'Please refer to your local waste management guidelines for proper disposal of this material.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(context),
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Popular Section
                    _buildPopularSection(context),
                    
                    const SizedBox(height: 24),
                    
                    // Other Section
                    _buildOtherSection(context),
                  ],
                ),
              ),
            ),
            
            // Bottom Navigation
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          const Text(
            'Sorting guide',
            style: AppTextStyles.headlineMedium,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  size: 18,
                  color: AppColors.gray700,
                ),
                const SizedBox(width: 4),
                Text(
                  'Search',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.gray700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              const Text(
                'Popular',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5D9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '🔥',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Category List
          _buildCategoryItem(
            context: context,
            icon: '🍶',
            label: 'Glass',
            color: const Color(0xFFB8D4C8),
          ),
          _buildCategoryItem(
            context: context,
            icon: '🍎',
            label: 'Food waste',
            color: const Color(0xFFD4E5B8),
          ),
          _buildCategoryItem(
            context: context,
            icon: '🔋',
            label: 'Batteries',
            color: const Color(0xFFE5D4B8),
          ),
          _buildCategoryItem(
            context: context,
            icon: '📦',
            label: 'Paper-cardboard',
            color: const Color(0xFFD4A574),
          ),
          _buildCategoryItem(
            context: context,
            icon: '📱',
            label: 'Electronics',
            color: const Color(0xFFB8B8D4),
          ),
          _buildCategoryItem(
            context: context,
            icon: '🌿',
            label: 'Green Waste',
            color: const Color(0xFFB8E5D4),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildOtherSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              const Text(
                'Other',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: AppColors.gray700,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Category List
          _buildCategoryItem(
            context: context,
            icon: '💊',
            label: 'Medication',
            color: const Color(0xFFFFD4D4),
          ),
          _buildCategoryItem(
            context: context,
            icon: '🧴',
            label: 'Hazardous waste',
            color: const Color(0xFFFFE5B8),
          ),
          _buildCategoryItem(
            context: context,
            icon: '🪑',
            label: 'Bulky waste',
            color: const Color(0xFFD4D4E5),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required BuildContext context,
    required String icon,
    required String label,
    required Color color,
    bool isLast = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            _showCategoryDetail(context, icon, label);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Label
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.gray900,
                    ),
                  ),
                ),
                
                // Arrow
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.gray500,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            color: AppColors.gray200,
          ),
      ],
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                isActive: false,
                color: AppColors.gray500,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _buildNavItem(
                icon: Icons.calendar_today_outlined,
                label: 'Calendar',
                isActive: false,
                color: AppColors.gray500,
              ),
              _buildNavItem(
                icon: Icons.location_on_outlined,
                label: 'Location',
                isActive: false,
                color: AppColors.gray500,
              ),
              _buildNavItem(
                icon: Icons.sort,
                label: 'Sorting',
                isActive: true,
                color: AppColors.primary500,
              ),
              _buildNavItem(
                icon: Icons.menu,
                label: 'Menu',
                isActive: false,
                color: AppColors.gray500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: 32,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}
