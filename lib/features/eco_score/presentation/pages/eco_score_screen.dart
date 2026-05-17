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

/// Eco score screen showing environmental impact and gamification.
///
/// Features:
/// - Total eco points display
/// - Statistics (weight recycled, items sold, pickups)
/// - Current badge and progress
/// - Point history
/// - Milestones
/// - Streak tracking
class EcoScoreScreen extends StatefulWidget {
  const EcoScoreScreen({super.key});

  @override
  State<EcoScoreScreen> createState() => _EcoScoreScreenState();
}

class _EcoScoreScreenState extends State<EcoScoreScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EcoBloc>().add(const LoadEcoStatsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
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
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary500,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(stats),
            ),
            title: const Text('Eco Score'),
          ),

          // Stats Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          '${stats.totalWeightRecycled.toStringAsFixed(1)} kg',
                          'Recycled',
                          Icons.recycling,
                          AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          '${stats.itemsSold}',
                          'Items Sold',
                          Icons.sell,
                          AppColors.accent500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          '${stats.pickupsCompleted}',
                          'Pickups',
                          Icons.local_shipping,
                          AppColors.secondary500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          '${stats.co2Reduced.toStringAsFixed(1)} kg',
                          'CO₂ Reduced',
                          Icons.cloud_outlined,
                          AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Streak Card
                  _buildStreakCard(stats),
                  const SizedBox(height: 24),

                  // Milestones
                  Text(
                    'Milestones',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...stats.milestones.map((milestone) => _buildMilestoneCard(milestone)),
                  const SizedBox(height: 24),

                  // Point History
                  Text(
                    'Point History',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // History List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = history[index];
                return _buildHistoryItem(entry);
              },
              childCount: history.length,
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(EcoStats stats) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary500,
            AppColors.primary700,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Badge Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco,
                  size: 48,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 16),
              // Total Points
              Text(
                '${stats.totalPoints}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total Eco Points',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 8),
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${stats.currentBadge.displayName} Badge',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray600,
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
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withOpacity(0.1),
            AppColors.warning.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: AppColors.warning,
              size: 32,
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
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Longest: ${stats.longestStreak} days',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray600,
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: milestone.isAchieved ? AppColors.success : AppColors.gray300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: milestone.isAchieved
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              milestone.isAchieved ? Icons.check_circle : Icons.lock_outline,
              color: milestone.isAchieved ? AppColors.success : AppColors.gray500,
              size: 24,
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
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  milestone.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${milestone.requiredPoints} pts',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(PointHistory entry) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add,
              color: AppColors.primary500,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.reason,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(entry.date),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${entry.points}',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.primary500,
              fontWeight: FontWeight.bold,
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
