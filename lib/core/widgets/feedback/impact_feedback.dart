import 'package:flutter/material.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/eco_levels.dart';
import 'package:felo_na/core/constants/spacing.dart';

/// Impact feedback widget — shown after meaningful actions
/// (pickup completion, item listing, etc.)
///
/// Displays:
/// - Emotional message with emoji (e.g. "🌱 You saved 3.2kg waste from landfill")
/// - Animated counter for the impact number
/// - Eco points earned
/// - Level progress bar
class ImpactFeedback extends StatefulWidget {
  /// The impact message (e.g. "You saved 3.2kg waste from landfill")
  final String message;

  /// Leading emoji for the message
  final String emoji;

  /// The numeric impact value to animate (e.g. 3.2)
  final double impactValue;

  /// Unit for the impact value (e.g. "kg")
  final String impactUnit;

  /// Eco points earned from this action
  final int pointsEarned;

  /// User's total eco points (after earning)
  final int totalPoints;

  const ImpactFeedback({
    super.key,
    required this.message,
    this.emoji = '🌱',
    required this.impactValue,
    this.impactUnit = 'kg',
    required this.pointsEarned,
    required this.totalPoints,
  });

  /// Show as a modal bottom sheet
  static Future<void> show(
    BuildContext context, {
    required String message,
    String emoji = '🌱',
    required double impactValue,
    String impactUnit = 'kg',
    required int pointsEarned,
    required int totalPoints,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ImpactFeedback(
        message: message,
        emoji: emoji,
        impactValue: impactValue,
        impactUnit: impactUnit,
        pointsEarned: pointsEarned,
        totalPoints: totalPoints,
      ),
    );
  }

  @override
  State<ImpactFeedback> createState() => _ImpactFeedbackState();
}

class _ImpactFeedbackState extends State<ImpactFeedback>
    with TickerProviderStateMixin {
  late AnimationController _counterController;
  late AnimationController _fadeController;
  late Animation<double> _counterAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _counterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _counterAnimation = Tween<double>(begin: 0, end: widget.impactValue).animate(
      CurvedAnimation(parent: _counterController, curve: Curves.easeOutCubic),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    final level = EcoLevels.fromPoints(widget.totalPoints);
    _progressAnimation = Tween<double>(
      begin: 0,
      end: level.progressFor(widget.totalPoints),
    ).animate(
      CurvedAnimation(parent: _counterController, curve: Curves.easeOutCubic),
    );

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _counterController.forward();
    });
  }

  @override
  void dispose() {
    _counterController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = EcoLevels.fromPoints(widget.totalPoints);
    final nextLevel = EcoLevels.nextLevel(widget.totalPoints);
    final levelNum = EcoLevels.levelNumber(widget.totalPoints);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.only(top: 80),
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
            left: BorderSide(color: AppColors.border, width: 1),
            right: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Spacing.gap24,

                // Emoji + animated counter
                AnimatedBuilder(
                  animation: _counterAnimation,
                  builder: (context, _) {
                    return Text(
                      '${widget.emoji} ${_counterAnimation.value.toStringAsFixed(1)}${widget.impactUnit}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                      ),
                    );
                  },
                ),
                Spacing.gap8,

                // Message
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Spacing.gap24,

                // Points earned badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.accentYellow, size: 18),
                      Spacing.hGap8,
                      Text(
                        '+${widget.pointsEarned} eco points',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                Spacing.gap24,

                // Level progress
                Row(
                  children: [
                    Text(
                      '${level.emoji} ${level.name}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Level $levelNum',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                Spacing.gap8,

                // Progress bar
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progressAnimation.value,
                        minHeight: 8,
                        backgroundColor: AppColors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(level.color),
                      ),
                    );
                  },
                ),
                Spacing.gap8,

                // Next level hint
                if (nextLevel != null)
                  Text(
                    '${level.pointsToNext(widget.totalPoints)} pts to ${nextLevel.name} ${nextLevel.emoji}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                Spacing.gap16,

                // Dismiss button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                    ),
                    child: const Text(
                      'Keep going! 💚',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
