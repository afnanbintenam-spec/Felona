import 'package:flutter/material.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/app_text_styles.dart';

class NextCollectionScreen extends StatelessWidget {
  const NextCollectionScreen({super.key});

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
                    // Collection Date Card
                    _buildCollectionDateCard(),
                    
                    const SizedBox(height: 24),
                    
                    // Your Schedule Section
                    _buildScheduleSection(),
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
            'Next collection',
            style: AppTextStyles.headlineMedium,
          ),
          const Spacer(),
          Image.asset(
            'Assets/mainLogo.png',
            width: 32,
            height: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionDateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
          // Date
          const Text(
            'Wednesday,',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          const Text(
            'May 22',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 8),
          
          // Last Update
          Text(
            'Last update: May 17',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray700,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Waste Categories
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildWasteChip(
                icon: '📦',
                label: 'Paper-cardboard',
                color: const Color(0xFFD4A574),
              ),
              _buildWasteChip(
                icon: '🗑️',
                label: 'Residual waste',
                color: const Color(0xFFB8B8D4),
              ),
              _buildWasteChip(
                icon: '♻️',
                label: 'PMD',
                color: const Color(0xFFB8D4C8),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Location Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: AppColors.gray700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Location',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteChip({
    required String icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.gray900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'upcoming collections',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.gray700,
          ),
        ),
        const SizedBox(height: 16),
        
        // Placeholder for schedule list
        Container(
          height: 200,
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
          child: Center(
            child: Text(
              'Schedule list coming soon',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray500,
              ),
            ),
          ),
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
                isActive: true,
                color: AppColors.primary500,
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
                isActive: false,
                color: AppColors.gray500,
                onTap: () {
                  Navigator.pushNamed(context, '/sorting-guide');
                },
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
