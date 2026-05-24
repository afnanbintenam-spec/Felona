import 'package:flutter/material.dart';

/// Eco Level System — gamification layer for FeloNa
/// Users progress through nature-themed levels as they earn eco points.
class EcoLevel {
  final String name;
  final String emoji;
  final int minPoints;
  final int maxPoints;
  final Color color;

  const EcoLevel({
    required this.name,
    required this.emoji,
    required this.minPoints,
    required this.maxPoints,
    required this.color,
  });

  /// Display string: "Seed 🌱"
  String get display => '$name $emoji';

  /// Progress within this level (0.0 to 1.0)
  double progressFor(int points) {
    if (points >= maxPoints) return 1.0;
    if (points < minPoints) return 0.0;
    return (points - minPoints) / (maxPoints - minPoints);
  }

  /// Points needed to reach the next level
  int pointsToNext(int points) {
    if (points >= maxPoints) return 0;
    return maxPoints - points + 1;
  }
}

/// All eco levels in ascending order
class EcoLevels {
  static const List<EcoLevel> all = [
    EcoLevel(
      name: 'Seed',
      emoji: '🌱',
      minPoints: 0,
      maxPoints: 200,
      color: Color(0xFFA5D6A7), // mintGreen
    ),
    EcoLevel(
      name: 'Sprout',
      emoji: '🌿',
      minPoints: 201,
      maxPoints: 500,
      color: Color(0xFF81C784), // lightGreen
    ),
    EcoLevel(
      name: 'Tree',
      emoji: '🌳',
      minPoints: 501,
      maxPoints: 1000,
      color: Color(0xFF4CAF50), // primaryGreen
    ),
    EcoLevel(
      name: 'Forest',
      emoji: '🌲',
      minPoints: 1001,
      maxPoints: 2000,
      color: Color(0xFF2E7D32), // deepGreen
    ),
    EcoLevel(
      name: 'Earth',
      emoji: '🌍',
      minPoints: 2001,
      maxPoints: 999999,
      color: Color(0xFF26A69A), // tealGreen
    ),
  ];

  /// Get the eco level for a given point total
  static EcoLevel fromPoints(int points) {
    for (final level in all.reversed) {
      if (points >= level.minPoints) return level;
    }
    return all.first;
  }

  /// Get the numeric level index (1-based)
  static int levelNumber(int points) {
    for (int i = all.length - 1; i >= 0; i--) {
      if (points >= all[i].minPoints) return i + 1;
    }
    return 1;
  }

  /// Get the next level (or null if at max)
  static EcoLevel? nextLevel(int points) {
    final current = fromPoints(points);
    final idx = all.indexOf(current);
    if (idx < all.length - 1) return all[idx + 1];
    return null;
  }
}
