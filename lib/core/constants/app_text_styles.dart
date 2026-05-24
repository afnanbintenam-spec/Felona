import 'package:flutter/material.dart';
import 'app_colors.dart';

/// FELO NA — Dark Teal Typography
class AppTextStyles {
  static const String _font = 'Inter';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _font, fontSize: 34, height: 1.15,
    fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5,
  );
  static const TextStyle displayMedium = TextStyle(
    fontFamily: _font, fontSize: 28, height: 1.2,
    fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3,
  );
  static const TextStyle displaySmall = TextStyle(
    fontFamily: _font, fontSize: 24, height: 1.25,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _font, fontSize: 20, height: 1.3,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _font, fontSize: 18, height: 1.35,
    fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _font, fontSize: 16, height: 1.4,
    fontWeight: FontWeight.w500, color: AppColors.textPrimary,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _font, fontSize: 16, height: 1.5,
    fontWeight: FontWeight.w400, color: AppColors.textPrimary,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _font, fontSize: 14, height: 1.5,
    fontWeight: FontWeight.w400, color: AppColors.textSecondary,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _font, fontSize: 12, height: 1.4,
    fontWeight: FontWeight.w400, color: AppColors.textTertiary,
  );
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _font, fontSize: 14, height: 1.4,
    fontWeight: FontWeight.w500, color: AppColors.textPrimary,
  );
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _font, fontSize: 12, height: 1.35,
    fontWeight: FontWeight.w500, color: AppColors.textSecondary,
  );
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _font, fontSize: 10, height: 1.4,
    fontWeight: FontWeight.w500, color: AppColors.textTertiary,
  );
}
