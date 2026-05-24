import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/eco_levels.dart';
import 'package:felo_na/core/constants/spacing.dart';

/// Dashboard — Dark Teal Eco Premium (Experience-based)
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ringController;

  // TODO: Replace with real user data from BLoC
  final int _userPoints = 1250;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: Spacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Spacing.gap16,
              _buildHeader(context),
              Spacing.gap32,
              _buildEcoScoreCard(),
              Spacing.gap24,
              _buildAIScanButton(context),
              Spacing.gap24,
              _buildStatsRow(),
              Spacing.gap24,
              _buildUpcomingPickup(context),
              Spacing.gap32,
              _buildQuickActions(context),
              Spacing.gap32,
              _buildRecentActivity(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final level = EcoLevels.fromPoints(_userPoints);
    final levelNum = EcoLevels.levelNumber(_userPoints);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.card,
                border: Border.all(color: AppColors.primaryGreen, width: 2),
              ),
              child: const Center(
                child: Text('A', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                )),
              ),
            ),
            Spacing.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${level.display} • Level $levelNum',
                    style: TextStyle(
                      fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500,
                      color: level.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text('Hello, Afnan', style: TextStyle(
                    fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
                ],
              ),
            ),
            _iconBtn(Icons.notifications_outlined, () {
              Navigator.pushNamed(context, '/notifications');
            }),
          ],
        ),
        Spacing.gap12,
        // Motivational message
        const Text(
          'Every small action creates a ripple 🌊',
          style: TextStyle(
            fontFamily: 'Inter', fontSize: 13, color: AppColors.textTertiary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: AppColors.card,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }

  // ─── ECO SCORE CARD (with level progress) ─────────────────────
  Widget _buildEcoScoreCard() {
    final level = EcoLevels.fromPoints(_userPoints);
    final nextLevel = EcoLevels.nextLevel(_userPoints);
    final progress = level.progressFor(_userPoints);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          // Score ring
          AnimatedBuilder(
            animation: _ringController,
            builder: (_, _) {
              return SizedBox(
                width: 100, height: 100,
                child: CustomPaint(
                  painter: _EcoRingPainter(
                    progress: _ringController.value * progress,
                    color: level.color,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(level.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 2),
                        Text(level.name, style: TextStyle(
                          fontFamily: 'Inter', fontSize: 11,
                          fontWeight: FontWeight.w600, color: level.color,
                        )),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Spacing.hGap16,
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_userPoints eco points',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Spacing.gap8,
                // Progress bar to next level
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.surface,
                    valueColor: AlwaysStoppedAnimation<Color>(level.color),
                  ),
                ),
                Spacing.gap8,
                if (nextLevel != null)
                  Text(
                    '${level.pointsToNext(_userPoints)} pts to ${nextLevel.name} ${nextLevel.emoji}',
                    style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary,
                    ),
                  )
                else
                  const Text(
                    'Max level reached! 🌍',
                    style: TextStyle(
                      fontFamily: 'Inter', fontSize: 12, color: AppColors.tealGreen,
                    ),
                  ),
                Spacing.gap4,
                const Text('Last 30 days: +245 pts', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 12, color: AppColors.textSecondary,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── AI SCAN BUTTON ───────────────────────────────────────────
  Widget _buildAIScanButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/waste-scanner'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.3),
              blurRadius: 16, offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 22),
            ),
            Spacing.hGap16,
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Scan Waste', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w700,
                  color: Colors.white,
                )),
                SizedBox(height: 2),
                Text('AI identifies & categorizes instantly', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 12, color: Colors.white70,
                )),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }

  // ─── STATS ROW ────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _statCard('12', 'Recycled', Icons.recycling_rounded)),
        Spacing.hGap12,
        Expanded(child: _statCard('8', 'Listed', Icons.sell_rounded)),
        Spacing.hGap12,
        Expanded(child: _statCard('3', 'Pickups', Icons.local_shipping_rounded)),
      ],
    );
  }

  Widget _statCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 22),
          Spacing.gap8,
          Text(value, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          )),
          Spacing.gap4,
          Text(label, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 11, color: AppColors.textTertiary,
          )),
        ],
      ),
    );
  }

  // ─── UPCOMING PICKUP ──────────────────────────────────────────
  Widget _buildUpcomingPickup(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.schedule_rounded, color: AppColors.primaryGreen, size: 22),
          ),
          Spacing.hGap12,
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Next Pickup', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 13, color: AppColors.textTertiary,
                )),
                SizedBox(height: 2),
                Text('Tomorrow, 2:30 PM', style: TextStyle(
                  fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                )),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 22),
        ],
      ),
    );
  }

  // ─── QUICK ACTIONS ────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _actionCard(
          icon: Icons.favorite_outline_rounded, label: 'Give it a new life',
          onTap: () => Navigator.pushNamed(context, '/create-listing'),
        )),
        Spacing.hGap12,
        Expanded(child: _actionCard(
          icon: Icons.local_shipping_outlined, label: 'Schedule rescue',
          onTap: () => Navigator.pushNamed(context, '/create-pickup'),
        )),
      ],
    );
  }

  Widget _actionCard({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryGreen, size: 22),
            ),
            Spacing.gap8,
            Text(label, textAlign: TextAlign.center, style: const TextStyle(
              fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            )),
          ],
        ),
      ),
    );
  }

  // ─── RECENT ACTIVITY (emotional copy) ─────────────────────────
  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Activity', style: TextStyle(
          fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        )),
        Spacing.gap16,
        _activityTile(
          Icons.eco_rounded,
          AppColors.success,
          '🌱 +50 points — growing your impact!',
          '2h ago',
        ),
        Spacing.gap8,
        _activityTile(
          Icons.favorite_rounded,
          AppColors.accentOrange,
          '💚 Someone wants to give your item a second life',
          '5h ago',
        ),
        Spacing.gap8,
        _activityTile(
          Icons.public_rounded,
          AppColors.accentBlue,
          '🌍 3.2kg saved from landfill!',
          '1 day ago',
        ),
      ],
    );
  }

  Widget _activityTile(IconData icon, Color color, String title, String time) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Spacing.hGap12,
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(
                fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              )),
              Text(time, style: const TextStyle(
                fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary,
              )),
            ],
          )),
        ],
      ),
    );
  }
}

// ─── ECO RING PAINTER ─────────────────────────────────────────────
class _EcoRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  _EcoRingPainter({required this.progress, this.color = AppColors.primaryGreen});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background ring
    canvas.drawCircle(center, radius, Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round);

    // Progress
    final sweep = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, sweep, false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _EcoRingPainter old) =>
      old.progress != progress || old.color != color;
}
