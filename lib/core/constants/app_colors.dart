import 'package:flutter/material.dart';

/// Premium Dark Theme Color Palette
/// Inspired by modern fintech apps with high contrast and neon accents
class AppColors {
  // Primary Colors - Vibrant Lime Green (Neon Accent)
  static const Color primary900 = Color(0xFF8FBF00); // Darker lime
  static const Color primary700 = Color(0xFFB8E600); // Deep lime
  static const Color primary500 = Color(0xFFD7FF00); // Vibrant Lime Green (Main)
  static const Color primary300 = Color(0xFFE3FF4D); // Light lime
  static const Color primary200 = Color(0xFFEBFF80); // Lighter lime
  static const Color primary100 = Color(0xFFF5FFB3); // Pale lime
  static const Color primary50 = Color(0xFFFAFFE6); // Very pale lime

  // Secondary Colors - Deep Charcoal (Card Surfaces)
  static const Color secondary900 = Color(0xFF0A0A0A); // Almost black
  static const Color secondary700 = Color(0xFF141414); // Very dark grey
  static const Color secondary500 = Color(0xFF1C1C1E); // Deep Charcoal (Main)
  static const Color secondary300 = Color(0xFF2C2C2E); // Medium charcoal
  static const Color secondary100 = Color(0xFF3A3A3C); // Light charcoal

  // Accent Colors - Electric Blue (Secondary Accent)
  static const Color accent900 = Color(0xFF0066CC);
  static const Color accent700 = Color(0xFF0080FF);
  static const Color accent500 = Color(0xFF00A3FF); // Electric Blue
  static const Color accent300 = Color(0xFF4DC3FF);
  static const Color accent100 = Color(0xFFB3E5FF);

  // Semantic Colors (Adjusted for dark theme)
  static const Color success = Color(0xFF00FF88); // Neon green
  static const Color warning = Color(0xFFFFB800); // Bright amber
  static const Color error = Color(0xFFFF3B30); // Bright red
  static const Color info = Color(0xFF00A3FF); // Electric blue

  // Neutral Colors (Dark Theme Optimized)
  static const Color gray900 = Color(0xFFFFFFFF); // White text on dark
  static const Color gray700 = Color(0xFFE5E5E7); // Light grey text
  static const Color gray600 = Color(0xFFAEAEB2); // Medium-light grey
  static const Color gray500 = Color(0xFF8E8E93); // Medium grey
  static const Color gray400 = Color(0xFF636366); // Medium-dark grey
  static const Color gray300 = Color(0xFF48484A); // Dark grey
  static const Color gray200 = Color(0xFF3A3A3C); // Darker grey
  static const Color gray100 = Color(0xFF2C2C2E); // Very dark grey
  static const Color gray50 = Color(0xFF000000); // Pure black (changed from charcoal)

  // Base Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000); // Pure Black Background

  // Special Effects
  static const Color neonGlow = Color(0xFFD7FF00); // Lime glow effect
  static const Color cardSurface = Color(0xFF1C1C1E); // Card background
  static const Color divider = Color(0xFF2C2C2E); // Subtle dividers
  
  // Background gradient colors (for special screens)
  static const Color backgroundDark = Color(0xFF000000);
  static const Color backgroundCharcoal = Color(0xFF1C1C1E);
  static const Color backgroundLight = Color(0xFF1C1C1E); // Alias for compatibility
}
