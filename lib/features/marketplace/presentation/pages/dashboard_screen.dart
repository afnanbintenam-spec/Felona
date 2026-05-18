import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/app_text_styles.dart';

/// Premium Dashboard Screen — Pixel-perfect dark theme
/// Matches the reference design: dark background, green gradient hero card,
/// dark cards with subtle green borders, floating action buttons with glow
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              _buildGreeting(),
              const SizedBox(height: 20),
              _buildEcoPointsCard(),
              const SizedBox(height: 16),
              _buildStatsRow(),
              const SizedBox(height: 16),
              _buildPickupScheduleCard(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 28),
              _buildRecentActivity(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ─── TOP BAR ──────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          // Logo + Brand
          Row(
            children: [
              Image.asset(
                'Assets/mainLogo.png',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              const Text(
                'FeloNa',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentGreen,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Notification bell
          _buildIconButton(Icons.notifications_outlined, () {
            Navigator.pushNamed(context, '/notifications');
          }),
          const SizedBox(width: 12),
          // Avatar
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accentGreen.withValues(alpha: 0.4),
                  width: 2,
                ),
                color: const Color(0xFF1A1A1A),
              ),
              child: const ClipOval(
                child: Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF2A2A2A),
            width: 1,
          ),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }

  // ─── GREETING ─────────────────────────────────────────────────
  Widget _buildGreeting() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good Morning,',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Afnan 👋',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Let's make the planet better today.",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  // ─── ECO POINTS HERO CARD ─────────────────────────────────────
  Widget _buildEcoPointsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4A7A00), // Dark green
              Color(0xFF8BC34A), // Medium green
              Color(0xFFCDDC39), // Lime
              Color(0xFFD9FF00), // Bright lime
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentGreen.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ECO POINTS label
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'ECO POINTS',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Big score
            const Text(
              '1,250',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.0,
              ),
            ),
            const Text(
              'pts',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),

            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '📈',
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Top recycler this week',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── STATS ROW ────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.sell_rounded,
              iconColor: AppColors.accentGreen,
              value: '8',
              label: 'Items Listed',
              hasViewAll: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.local_shipping_rounded,
              iconColor: AppColors.accentGreen,
              value: '3',
              label: 'Awaiting Pickup',
              hasViewAll: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    bool hasViewAll = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentGreen.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          if (hasViewAll) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'View all',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accentGreen.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: AppColors.accentGreen.withValues(alpha: 0.8),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── PICKUP SCHEDULE CARD ─────────────────────────────────────
  Widget _buildPickupScheduleCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.accentGreen.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Left content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.calendar_today_rounded,
                          color: AppColors.accentGreen,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pickup scheduled',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Tomorrow, 2:30 PM',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'See details',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.accentGreen.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 14,
                        color: AppColors.accentGreen.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Right: Truck illustration placeholder
            Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.local_shipping_rounded,
                size: 40,
                color: AppColors.accentGreen.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── QUICK ACTIONS ────────────────────────────────────────────
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // List an Item
          _buildActionButton(
            icon: Icons.add_rounded,
            label: 'List an Item',
            onTap: () => Navigator.pushNamed(context, '/create-listing'),
          ),
          const SizedBox(width: 40),
          // Request Pickup
          _buildActionButton(
            icon: Icons.local_shipping_rounded,
            label: 'Request Pickup',
            onTap: () => Navigator.pushNamed(context, '/create-pickup'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1A1A1A),
                  border: Border.all(
                    color: AppColors.accentGreen.withValues(
                      alpha: 0.3 + (_glowController.value * 0.3),
                    ),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentGreen.withValues(
                        alpha: 0.1 + (_glowController.value * 0.1),
                      ),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: AppColors.accentGreen,
                  size: 26,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  // ─── RECENT ACTIVITY ──────────────────────────────────────────
  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                'View All',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accentGreen.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Activity items
          _buildActivityItem(
            icon: Icons.check_circle_rounded,
            iconBgColor: const Color(0xFF0A2E0A),
            iconColor: AppColors.success,
            title: 'Earned 50 eco points',
            subtitle: '2 hours ago',
            badge: '+50 pts',
            badgeColor: AppColors.accentGreen,
          ),
          const SizedBox(height: 10),
          _buildActivityItem(
            icon: Icons.play_arrow_rounded,
            iconBgColor: const Color(0xFF1A1040),
            iconColor: const Color(0xFF8B5CF6),
            title: 'Someone offered \$25 for your item',
            subtitle: '5 hours ago',
            badge: '+\$25',
            badgeColor: AppColors.accentGreen,
          ),
          const SizedBox(height: 10),
          _buildActivityItem(
            icon: Icons.local_shipping_rounded,
            iconBgColor: const Color(0xFF2E1A0A),
            iconColor: const Color(0xFFFF8C00),
            title: 'Pickup completed',
            subtitle: '1 day ago',
            badge: 'Completed',
            badgeColor: AppColors.accentGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1E1E1E),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: badgeColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
