import 'package:flutter/material.dart';
import 'package:felo_na/core/constants/app_colors.dart';

/// Premium Dark Theme — Klima-inspired
/// Headlines: Finlandica | Body: Inter
/// Nature-forward, clean, high-contrast
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGreen,
        onPrimary: Colors.white,
        secondary: AppColors.tealGreen,
        onSecondary: Colors.white,
        surface: AppColors.background,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.background,

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Finlandica',
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontFamily: 'Inter',
        ),
        labelStyle: const TextStyle(
          color: AppColors.textTertiary,
          fontFamily: 'Inter',
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: CircleBorder(),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.card,
        selectedColor: AppColors.primaryGreen,
        labelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'Inter',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),

      // Icon
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 24,
      ),

      // Typography
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary, fontFamily: 'Finlandica',
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 30, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary, fontFamily: 'Finlandica',
          letterSpacing: -0.3,
        ),
        displaySmall: TextStyle(
          fontSize: 26, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary, fontFamily: 'Finlandica',
        ),
        headlineLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary, fontFamily: 'Finlandica',
        ),
        headlineMedium: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary, fontFamily: 'Finlandica',
        ),
        headlineSmall: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w500,
          color: AppColors.textPrimary, fontFamily: 'Finlandica',
        ),
        bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w400,
          color: AppColors.textPrimary, fontFamily: 'Inter',
        ),
        bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400,
          color: AppColors.textSecondary, fontFamily: 'Inter',
        ),
        bodySmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w400,
          color: AppColors.textTertiary, fontFamily: 'Inter',
        ),
        labelLarge: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500,
          color: AppColors.textPrimary, fontFamily: 'Inter',
        ),
        labelMedium: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500,
          color: AppColors.textSecondary, fontFamily: 'Inter',
        ),
        labelSmall: TextStyle(
          fontSize: 10, fontWeight: FontWeight.w500,
          color: AppColors.textTertiary, fontFamily: 'Inter',
        ),
      ),
    );
  }
}
