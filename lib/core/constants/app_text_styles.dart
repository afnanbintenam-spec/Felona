import 'package:flutter/material.dart';
import 'app_colors.dart';

/// FELO NA — Typography System
/// Headlines: Finlandica (bold, expressive)
/// Body/Labels: Inter (clean, readable)
class AppTextStyles {
  static const String _headlineFont = 'Finlandica';
  static const String _bodyFont = 'Inter';

  // ─── Headlines (Finlandica) ─────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _headlineFont, fontSize: 36, height: 1.15,
    fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5,
  );
  static const TextStyle displayMedium = TextStyle(
    fontFamily: _headlineFont, fontSize: 30, height: 1.2,
    fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3,
  );
  static const TextStyle displaySmall = TextStyle(
    fontFamily: _headlineFont, fontSize: 26, height: 1.25,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _headlineFont, fontSize: 22, height: 1.3,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _headlineFont, fontSize: 20, height: 1.35,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _headlineFont, fontSize: 18, height: 1.4,
    fontWeight: FontWeight.w500, color: AppColors.textPrimary,
  );

  // ─── Body (Inter) ──────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _bodyFont, fontSize: 16, height: 1.5,
    fontWeight: FontWeight.w400, color: AppColors.textPrimary,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _bodyFont, fontSize: 14, height: 1.5,
    fontWeight: FontWeight.w400, color: AppColors.textSecondary,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _bodyFont, fontSize: 12, height: 1.4,
    fontWeight: FontWeight.w400, color: AppColors.textTertiary,
  );

  // ─── Labels (Inter) ────────────────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _bodyFont, fontSize: 14, height: 1.4,
    fontWeight: FontWeight.w500, color: AppColors.textPrimary,
  );
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _bodyFont, fontSize: 12, height: 1.35,
    fontWeight: FontWeight.w500, color: AppColors.textSecondary,
  );
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _bodyFont, fontSize: 10, height: 1.4,
    fontWeight: FontWeight.w500, color: AppColors.textTertiary,
  );

  // ─── Button (Inter) ────────────────────────────────────────
  static const TextStyle button = TextStyle(
    fontFamily: _bodyFont, fontSize: 16, height: 1.4,
    fontWeight: FontWeight.w600, color: Colors.white,
  );
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: _bodyFont, fontSize: 14, height: 1.4,
    fontWeight: FontWeight.w600, color: Colors.white,
  );
}
