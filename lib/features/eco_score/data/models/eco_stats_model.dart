import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/features/eco_score/domain/entities/eco_stats.dart';

/// Data model for EcoStats with JSON serialization.
class EcoStatsModel extends EcoStats {
  const EcoStatsModel({
    required super.userId,
    required super.totalPoints,
    required super.totalWeightRecycled,
    required super.itemsSold,
    required super.pickupsCompleted,
    required super.co2Reduced,
    required super.currentBadge,
    required super.currentStreak,
    required super.longestStreak,
    required super.lastActivityDate,
    required super.milestones,
  });

  factory EcoStatsModel.fromJson(Map<String, dynamic> json) {
    return EcoStatsModel(
      userId: (json['user_id'] ?? json['userId']) as String,
      totalPoints: (json['total_points'] ?? json['totalPoints'] ?? 0) as int,
      totalWeightRecycled:
          ((json['total_weight_recycled'] ?? json['totalWeightRecycled'] ?? 0) as num).toDouble(),
      itemsSold: (json['items_sold'] ?? json['itemsSold'] ?? 0) as int,
      pickupsCompleted: (json['pickups_completed'] ?? json['pickupsCompleted'] ?? 0) as int,
      co2Reduced: ((json['co2_reduced'] ?? json['co2Reduced'] ?? 0) as num).toDouble(),
      currentBadge: _parseBadge(json['current_badge'] ?? json['currentBadge'] ?? 'beginner'),
      currentStreak: (json['current_streak'] ?? json['currentStreak'] ?? 0) as int,
      longestStreak: (json['longest_streak'] ?? json['longestStreak'] ?? 0) as int,
      lastActivityDate: DateTime.parse(
        (json['last_activity_date'] ?? json['lastActivityDate'] ?? DateTime.now().toIso8601String())
            as String,
      ),
      milestones: (json['milestones'] as List<dynamic>?)
              ?.map((m) => EcoMilestoneModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total_points': totalPoints,
      'total_weight_recycled': totalWeightRecycled,
      'items_sold': itemsSold,
      'pickups_completed': pickupsCompleted,
      'co2_reduced': co2Reduced,
      'current_badge': currentBadge.name,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_activity_date': lastActivityDate.toIso8601String(),
      'milestones': milestones
          .map((m) => {
                'id': m.id,
                'title': m.title,
                'description': m.description,
                'required_points': m.requiredPoints,
                'is_achieved': m.isAchieved,
                'achieved_at': m.achievedAt?.toIso8601String(),
              })
          .toList(),
    };
  }

  static EcoBadgeType _parseBadge(String value) {
    switch (value.toLowerCase()) {
      case 'bronze':
        return EcoBadgeType.bronze;
      case 'silver':
        return EcoBadgeType.silver;
      case 'gold':
        return EcoBadgeType.gold;
      case 'platinum':
        return EcoBadgeType.platinum;
      case 'champion':
        return EcoBadgeType.champion;
      default:
        return EcoBadgeType.beginner;
    }
  }
}

class EcoMilestoneModel extends EcoMilestone {
  const EcoMilestoneModel({
    required super.id,
    required super.title,
    required super.description,
    required super.requiredPoints,
    required super.isAchieved,
    super.achievedAt,
  });

  factory EcoMilestoneModel.fromJson(Map<String, dynamic> json) {
    return EcoMilestoneModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      requiredPoints: (json['required_points'] ?? json['requiredPoints'] ?? 0) as int,
      isAchieved: (json['is_achieved'] ?? json['isAchieved'] ?? false) as bool,
      achievedAt: (json['achieved_at'] ?? json['achievedAt']) != null
          ? DateTime.parse((json['achieved_at'] ?? json['achievedAt']) as String)
          : null,
    );
  }
}

class PointHistoryModel extends PointHistory {
  const PointHistoryModel({
    required super.id,
    required super.points,
    required super.reason,
    required super.date,
    super.relatedId,
  });

  factory PointHistoryModel.fromJson(Map<String, dynamic> json) {
    return PointHistoryModel(
      id: json['id'] as String,
      points: json['points'] as int,
      reason: json['reason'] as String,
      date: DateTime.parse(
        (json['date'] ?? json['created_at'] ?? DateTime.now().toIso8601String()) as String,
      ),
      relatedId: (json['related_id'] ?? json['relatedId']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'points': points,
      'reason': reason,
      'date': date.toIso8601String(),
      'related_id': relatedId,
    };
  }
}
