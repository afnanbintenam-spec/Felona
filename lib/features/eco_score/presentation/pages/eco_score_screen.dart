import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/app_text_styles.dart';
import 'package:felo_na/core/widgets/loading/loading_indicator.dart';
import 'package:felo_na/core/widgets/empty_states/empty_state.dart';
import 'package:felo_na/features/eco_score/presentation/bloc/eco_bloc.dart';
import 'package:felo_na/features/eco_score/presentation/bloc/eco_event.dart';
import 'package:felo_na/features/eco_score/presentation/bloc/eco_state.dart';
import 'package:felo_na/features/eco_score/domain/entities/eco_stats.dart';

/// Eco Score Screen — Premium Dark Theme
class EcoScoreScreen extends StatefulWidget {
  const EcoScoreScreen({super.key});

  @override
  State<EcoScoreScreen> createState() => _EcoScoreScreenState();
}

class _EcoScoreScreenState extends State<EcoScoreScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    context.read<EcoBloc>().add(const LoadEcoStatsRequested());
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<EcoBloc, EcoState>(
        builder: (context, state) {
          if (state is EcoLoading) {
            return const LoadingIndicator(message: 'Loading eco stats...');
          } else if (state is EcoError) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Error',
              description: state.message,
              actionLabel: 'Retry',
              onAction: () {
                context.read<EcoBloc>().add(const LoadEcoStatsRequested());
              },
            );
          } else if (state is EcoLoaded) {
            return _buildContent(state.stats, state.history);
          }

          return const EmptyState(
            icon: Icons.eco_outlined,
            title: 'Eco Score',
            description: 'Track your environmental impact',
          );
        },
      ),
    );
  }

  Widget _buildContent(EcoStats stats, List<PointHistory> history) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<EcoBloc>().add(const RefreshEcoStatsRequested());
      },
      color: AppColors.accentGreen,
      backgroundColor: AppColors.cardDark,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Eco Score',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),

                // Hero Score Card
                _buildHeroScoreCard(stats),
                const SizedBox(height: 24),

                // Stats Grid
                _buildStatsGrid(stats),
                const SizedBox(height: 24),

                // Streak Card
                _buildStreakCard(stats),
                const SizedBox(height: 32),

                // Milestones
                Text(
                  'Milestones',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ...stats.milestones
                    .map((milestone) => _buildMilestoneCard(milestone)),
                const SizedBox(height: 32),

                // Point History
                Text(
                  'Point History',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ...history.map((entry) => _buildHistoryItem(entry)),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroScoreCard(EcoStats stats) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: AppColors.cardDark,
            border: Border.all(
              color: AppColors.accentGreen.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentGreen.withValues(
                  alpha: 0.05 + (_glowController.value * 0.05),
                ),
                blurRadius: 40,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Column(
            children: [
              // Progress Ring + Score
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: _EcoRingPainter(
                    progress: stats.totalPoints / 2000,
                    glowIntensity: _glowController.value,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.eco_rounded,
                          color: AppColors.accentGreen,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${stats.totalPoints}',
                          style: AppTextStyles.displayMedium.copyWith(
                            color: AppColors.accentGreen,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Total Eco Points',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${stats.currentBadge.displayName} Badge',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(EcoStats stats) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildStatCard(
          '${stats.totalWeightRecycled.toStringAsFixed(1)} kg',
          'Recycled',
          Icons.recycling_rounded,
        ),
        _buildStatCard(
          '${stats.itemsSold}',
          'Items Sold',
          Icons.sell_rounded,
        ),
        _buildStatCard(
          '${stats.pickupsCompleted}',
          'Pickups',
          Icons.local_shipping_rounded,
        ),
        _buildStatCard(
          '${stats.co2Reduced.toStringAsFixed(1)} kg',
          'CO₂ Reduced',
          Icons.cloud_outlined,
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    final width = (MediaQuery.of(context).size.width - 60) / 2;
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accentGreen, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(EcoStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.warning,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stats.currentStreak} Day Streak! 🔥',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Longest: ${stats.longestStreak} days',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(EcoMilestone milestone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: milestone.isAchieved
              ? AppColors.accentGreen.withValues(alpha: 0.3)
              : AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: milestone.isAchieved
                  ? AppColors.accentGreen.withValues(alpha: 0.1)
                  : AppColors.glassWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              milestone.isAchieved
                  ? Icons.check_circle_rounded
                  : Icons.lock_outline_rounded,
              color: milestone.isAchieved
                  ? AppColors.accentGreen
                  : AppColors.textMuted,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  milestone.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${milestone.requiredPoints} pts',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(PointHistory entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.accentGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.reason,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(entry.date),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${entry.points}',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.accentGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// ─── ECO RING PAINTER ─────────────────────────────────────────────
class _EcoRingPainter extends CustomPainter {
  final double progress;
  final double glowIntensity;

  _EcoRingPainter({required this.progress, required this.glowIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background ring
    final bgPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final progressPaint = Paint()
      ..color = AppColors.accentGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final clampedProgress = progress.clamp(0.0, 1.0);
    final sweepAngle = 2 * math.pi * clampedProgress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Glow
    final glowPaint = Paint()
      ..color = AppColors.accentGreen.withValues(alpha: 0.15 * glowIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _EcoRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.glowIntensity != glowIntensity;
  }
}
