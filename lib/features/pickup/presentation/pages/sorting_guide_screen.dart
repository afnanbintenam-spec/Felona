import 'package:flutter/material.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/app_text_styles.dart';

class SortingGuideScreen extends StatelessWidget {
  const SortingGuideScreen({super.key});

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
                    _buildPopularSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Other Section
                    _buildOtherSection(),
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

  Widget _buildPopularSection() {
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
            icon: '🍶',
            label: 'Glass',
            color: const Color(0xFFB8D4C8),
          ),
          _buildCategoryItem(
            icon: '🍎',
            label: 'Food waste',
            color: const Color(0xFFD4E5B8),
          ),
          _buildCategoryItem(
            icon: '🔋',
            label: 'Batteries',
            color: const Color(0xFFE5D4B8),
          ),
          _buildCategoryItem(
            icon: '📦',
            label: 'Paper-cardboard',
            color: const Color(0xFFD4A574),
          ),
          _buildCategoryItem(
            icon: '📱',
            label: 'Electronics',
            color: const Color(0xFFB8B8D4),
          ),
          _buildCategoryItem(
            icon: '🌿',
            label: 'Green Waste',
            color: const Color(0xFFB8E5D4),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildOtherSection() {
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
            icon: '💊',
            label: 'Medication',
            color: const Color(0xFFFFD4D4),
          ),
          _buildCategoryItem(
            icon: '🧴',
            label: 'Hazardous waste',
            color: const Color(0xFFFFE5B8),
          ),
          _buildCategoryItem(
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
    required String icon,
    required String label,
    required Color color,
    bool isLast = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            // Navigate to category detail
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
