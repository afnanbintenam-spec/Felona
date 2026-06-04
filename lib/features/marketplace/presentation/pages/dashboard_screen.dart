import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/eco_levels.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/constants/spacing.dart';
import 'package:felo_na/features/auth/domain/entities/user.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_state.dart';
import 'package:felo_na/features/eco_score/presentation/bloc/eco_bloc.dart';
import 'package:felo_na/features/eco_score/presentation/bloc/eco_event.dart';
import 'package:felo_na/features/eco_score/presentation/bloc/eco_state.dart';
import 'package:felo_na/features/eco_score/domain/entities/eco_stats.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_bloc.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_event.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_state.dart';
import 'package:felo_na/features/pickup/domain/entities/pickup_request.dart';

/// Dashboard — Normal user home screen.
/// Stats and upcoming pickup are driven by real BLoC data.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    // Load real data on mount
    context.read<EcoBloc>().add(const LoadEcoStatsRequested());
    context.read<PickupBloc>().add(const LoadPickupsRequested());
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final User? user =
            authState is Authenticated ? authState.user : null;
        final int userPoints = user?.ecoPoints ?? 0;
        final String userName = user?.fullName ?? '';

        return Scaffold(
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            color: AppColors.primaryGreen,
            onRefresh: () async {
              context.read<EcoBloc>().add(const LoadEcoStatsRequested());
              context.read<PickupBloc>().add(const LoadPickupsRequested());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroHeader(context, userPoints, userName),
                  Padding(
                    padding: Spacing.pagePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Spacing.gap24,
                        _buildEcoScoreCard(userPoints),
                        Spacing.gap20,
                        _buildAIScanButton(context),
                        Spacing.gap20,
                        _buildStatsRow(),
                        Spacing.gap20,
                        _buildUpcomingPickup(context),
                        Spacing.gap24,
                        _buildQuickActions(context),
                        Spacing.gap24,
                        _buildRecentActivity(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── HERO HEADER ─────────────────────────────────────────────
  Widget _buildHeroHeader(
      BuildContext context, int userPoints, String userName) {
    final level = EcoLevels.fromPoints(userPoints);
    final levelNum = EcoLevels.levelNumber(userPoints);
    final avatarLetter =
        userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return Container(
      height: 220,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            child: Image.asset(
              'Assets/backgrounds/bg_ocean.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: AppColors.deepGreen),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                          border: Border.all(
                              color: AppColors.primaryGreen, width: 2),
                        ),
                        child: Center(
                          child: Text(avatarLetter,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
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
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userName.isNotEmpty
                                  ? 'Hello, $userName'
                                  : 'Hello!',
                              style: const TextStyle(
                                fontFamily: 'Finlandica',
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, '/notifications'),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_outlined,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Every small action creates a ripple 🌊',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── ECO SCORE CARD ──────────────────────────────────────────
  Widget _buildEcoScoreCard(int userPoints) {
    final level = EcoLevels.fromPoints(userPoints);
    final nextLevel = EcoLevels.nextLevel(userPoints);
    final progress = level.progressFor(userPoints);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _ringController,
            builder: (_, __) {
              return SizedBox(
                width: 90,
                height: 90,
                child: CustomPaint(
                  painter: _EcoRingPainter(
                    progress: _ringController.value * progress,
                    color: level.color,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(level.emoji,
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 2),
                        Text(level.name,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: level.color,
                            )),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Spacing.hGap16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$userPoints eco points',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Spacing.gap8,
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.surface,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(level.color),
                  ),
                ),
                Spacing.gap8,
                if (nextLevel != null)
                  Text(
                    '${level.pointsToNext(userPoints)} pts to ${nextLevel.name} ${nextLevel.emoji}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  )
                else
                  const Text(
                    'Max level reached! 🌍',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.tealGreen,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── AI SCAN BUTTON ──────────────────────────────────────────
  Widget _buildAIScanButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/waste-scanner'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  color: Colors.white, size: 22),
            ),
            Spacing.hGap16,
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Scan Waste',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                  SizedBox(height: 2),
                  Text('AI identifies & categorizes instantly',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Colors.white70,
                      )),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }

  // ─── STATS ROW — wired from EcoBloc ──────────────────────────
  Widget _buildStatsRow() {
    return BlocBuilder<EcoBloc, EcoState>(
      builder: (context, state) {
        final stats = state is EcoLoaded ? state.stats : null;

        final weightStr = stats != null
            ? '${stats.totalWeightRecycled.toStringAsFixed(1)}kg'
            : '—';
        final listedStr = stats != null ? '${stats.itemsSold}' : '—';
        final pickupStr =
            stats != null ? '${stats.pickupsCompleted}' : '—';

        return Row(
          children: [
            Expanded(
                child: _statCard(
                    weightStr, 'Recycled', Icons.recycling_rounded)),
            Spacing.hGap12,
            Expanded(
                child: _statCard(listedStr, 'Sold', Icons.sell_rounded)),
            Spacing.hGap12,
            Expanded(
                child: _statCard(
                    pickupStr, 'Pickups', Icons.local_shipping_rounded)),
          ],
        );
      },
    );
  }

  Widget _statCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 22),
          Spacing.gap8,
          Text(value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              )),
          Spacing.gap4,
          Text(label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.textTertiary,
              )),
        ],
      ),
    );
  }

  // ─── UPCOMING PICKUP — wired from PickupBloc ─────────────────
  Widget _buildUpcomingPickup(BuildContext context) {
    return BlocBuilder<PickupBloc, PickupState>(
      builder: (context, state) {
        PickupRequest? next;

        if (state is PickupLoaded) {
          // Find the soonest pending/accepted/on-the-way pickup
          final active = state.pickups.where((p) =>
              p.status == PickupStatus.pending ||
              p.status == PickupStatus.assigned ||
              p.status == PickupStatus.accepted ||
              p.status == PickupStatus.onTheWay);
          if (active.isNotEmpty) {
            // Sort by scheduled date ascending, then creation date
            final sorted = active.toList()
              ..sort((a, b) {
                final aDate = a.scheduledDate ?? a.createdAt;
                final bDate = b.scheduledDate ?? b.createdAt;
                return aDate.compareTo(bDate);
              });
            next = sorted.first;
          }
        }

        final String dateLabel;
        final String statusLabel;

        if (next != null) {
          final scheduled = next.scheduledDate;
          if (scheduled != null) {
            final now = DateTime.now();
            final diff = scheduled.difference(
                DateTime(now.year, now.month, now.day));
            if (diff.inDays == 0) {
              dateLabel =
                  'Today, ${next.timeSlot?.displayName ?? DateFormat('HH:mm').format(scheduled)}';
            } else if (diff.inDays == 1) {
              dateLabel =
                  'Tomorrow, ${next.timeSlot?.displayName ?? DateFormat('HH:mm').format(scheduled)}';
            } else {
              dateLabel =
                  '${DateFormat('EEE, MMM d').format(scheduled)} • ${next.timeSlot?.displayName ?? ''}';
            }
          } else {
            dateLabel = 'Unscheduled';
          }
          statusLabel = next.status.displayName;
        } else if (state is PickupLoading) {
          dateLabel = 'Loading…';
          statusLabel = '';
        } else {
          dateLabel = 'No upcoming pickup';
          statusLabel = '';
        }

        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/next-collection'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.schedule_rounded,
                      color: AppColors.primaryGreen, size: 22),
                ),
                Spacing.hGap12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        next != null ? 'Next Pickup' : 'Pickups',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateLabel,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (statusLabel.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: _pickupStatusColor(next?.status),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted, size: 22),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _pickupStatusColor(PickupStatus? status) {
    switch (status) {
      case PickupStatus.pending:
        return AppColors.warning;
      case PickupStatus.assigned:
        return const Color(0xFF9B59B6);
      case PickupStatus.accepted:
      case PickupStatus.onTheWay:
        return AppColors.info;
      default:
        return AppColors.textTertiary;
    }
  }

  // ─── QUICK ACTIONS ───────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _actionCard(
          icon: Icons.favorite_outline_rounded,
          label: 'Give it a\nnew life',
          onTap: () => Navigator.pushNamed(context, '/create-listing'),
        )),
        Spacing.hGap12,
        Expanded(
            child: _actionCard(
          icon: Icons.local_shipping_outlined,
          label: 'Schedule\nrescue',
          onTap: () => Navigator.pushNamed(context, '/create-pickup'),
        )),
      ],
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.primaryGreen.withValues(alpha: 0.25),
              width: 1),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryGreen, size: 24),
            ),
            Spacing.gap12,
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                )),
          ],
        ),
      ),
    );
  }

  // ─── RECENT ACTIVITY — wired from EcoBloc point history ──────
  Widget _buildRecentActivity() {
    return BlocBuilder<EcoBloc, EcoState>(
      builder: (context, state) {
        final history = state is EcoLoaded ? state.history : <PointHistory>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Activity',
                style: TextStyle(
                  fontFamily: 'Finlandica',
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                )),
            Spacing.gap16,
            if (history.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.eco_rounded,
                        color: AppColors.textTertiary, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'No activity yet. Start recycling!',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...history.take(5).map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _activityTile(
                      _activityIcon(entry.reason),
                      _activityColor(entry.points),
                      '${entry.points > 0 ? '+' : ''}${entry.points} pts — ${entry.reason}',
                      _formatActivityDate(entry.date),
                    ),
                  )),
          ],
        );
      },
    );
  }

  IconData _activityIcon(String reason) {
    final r = reason.toLowerCase();
    if (r.contains('pickup')) return Icons.local_shipping_rounded;
    if (r.contains('scan') || r.contains('waste')) return Icons.eco_rounded;
    if (r.contains('sell') || r.contains('listing')) {
      return Icons.favorite_rounded;
    }
    return Icons.public_rounded;
  }

  Color _activityColor(int points) {
    if (points > 0) return AppColors.success;
    return AppColors.accentOrange;
  }

  String _formatActivityDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }

  Widget _activityTile(
      IconData icon, Color color, String title, String time) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Spacing.hGap12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    )),
                Text(time,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ECO RING PAINTER ─────────────────────────────────────────────
class _EcoRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  _EcoRingPainter(
      {required this.progress, this.color = AppColors.primaryGreen});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = AppColors.border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round);

    final sweep = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _EcoRingPainter old) =>
      old.progress != progress || old.color != color;
}
