import 'package:equatable/equatable.dart';
import 'package:felo_na/core/constants/enums.dart';

/// Eco statistics entity representing user's environmental impact.
class EcoStats extends Equatable {
  final String userId;
  final int totalPoints;
  final double totalWeightRecycled; // in kg
  final int itemsSold;
  final int pickupsCompleted;
  final double co2Reduced; // in kg
  final EcoBadgeType currentBadge;
  final int currentStreak; // days
  final int longestStreak; // days
  final DateTime lastActivityDate;
  final List<EcoMilestone> milestones;

  const EcoStats({
    required this.userId,
    required this.totalPoints,
    required this.totalWeightRecycled,
    required this.itemsSold,
    required this.pickupsCompleted,
    required this.co2Reduced,
    required this.currentBadge,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActivityDate,
    required this.milestones,
  });

  EcoStats copyWith({
    String? userId,
    int? totalPoints,
    double? totalWeightRecycled,
    int? itemsSold,
    int? pickupsCompleted,
    double? co2Reduced,
    EcoBadgeType? currentBadge,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    List<EcoMilestone>? milestones,
  }) {
    return EcoStats(
      userId: userId ?? this.userId,
      totalPoints: totalPoints ?? this.totalPoints,
      totalWeightRecycled: totalWeightRecycled ?? this.totalWeightRecycled,
      itemsSold: itemsSold ?? this.itemsSold,
      pickupsCompleted: pickupsCompleted ?? this.pickupsCompleted,
      co2Reduced: co2Reduced ?? this.co2Reduced,
      currentBadge: currentBadge ?? this.currentBadge,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      milestones: milestones ?? this.milestones,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        totalPoints,
        totalWeightRecycled,
        itemsSold,
        pickupsCompleted,
        co2Reduced,
        currentBadge,
        currentStreak,
        longestStreak,
        lastActivityDate,
        milestones,
      ];
}

/// Eco milestone entity.
class EcoMilestone extends Equatable {
  final String id;
  final String title;
  final String description;
  final int requiredPoints;
  final bool isAchieved;
  final DateTime? achievedAt;

  const EcoMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredPoints,
    required this.isAchieved,
    this.achievedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        requiredPoints,
        isAchieved,
        achievedAt,
      ];
}

/// Point history entry.
class PointHistory extends Equatable {
  final String id;
  final int points;
  final String reason;
  final DateTime date;
  final String? relatedId; // pickup or listing id

  const PointHistory({
    required this.id,
    required this.points,
    required this.reason,
    required this.date,
    this.relatedId,
  });

  @override
  List<Object?> get props => [id, points, reason, date, relatedId];
}
