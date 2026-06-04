import 'package:flutter_test/flutter_test.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/features/eco_score/data/models/eco_stats_model.dart';
import 'package:felo_na/features/eco_score/domain/entities/eco_stats.dart';

void main() {
  final lastActivity = DateTime.utc(2024, 4, 20);
  final achievedAt = DateTime.utc(2024, 3, 1);

  // ─── fixtures ────────────────────────────────────────────

  Map<String, dynamic> milestoneJson({bool achieved = true}) => {
        'id': 'm1',
        'title': 'First Pickup',
        'description': 'Complete your first pickup',
        'required_points': 10,
        'is_achieved': achieved,
        'achieved_at': achieved ? achievedAt.toIso8601String() : null,
      };

  Map<String, dynamic> fullStatsJson() => {
        'user_id': 'u1',
        'total_points': 750,
        'total_weight_recycled': 23.5,
        'items_sold': 5,
        'pickups_completed': 8,
        'co2_reduced': 12.3,
        'current_badge': 'silver',
        'current_streak': 7,
        'longest_streak': 14,
        'last_activity_date': lastActivity.toIso8601String(),
        'milestones': [milestoneJson(), milestoneJson(achieved: false)],
      };

  // ─────────────────────────────────────────────────────────
  // EcoStatsModel.fromJson — snake_case
  // ─────────────────────────────────────────────────────────
  group('EcoStatsModel.fromJson snake_case', () {
    test('parses all numeric fields', () {
      final m = EcoStatsModel.fromJson(fullStatsJson());
      expect(m.userId, 'u1');
      expect(m.totalPoints, 750);
      expect(m.totalWeightRecycled, 23.5);
      expect(m.itemsSold, 5);
      expect(m.pickupsCompleted, 8);
      expect(m.co2Reduced, closeTo(12.3, 0.001));
    });

    test('parses currentBadge', () {
      expect(EcoStatsModel.fromJson(fullStatsJson()).currentBadge, EcoBadgeType.silver);
    });

    test('parses streak fields', () {
      final m = EcoStatsModel.fromJson(fullStatsJson());
      expect(m.currentStreak, 7);
      expect(m.longestStreak, 14);
    });

    test('parses lastActivityDate', () {
      expect(EcoStatsModel.fromJson(fullStatsJson()).lastActivityDate, lastActivity);
    });

    test('parses milestones list', () {
      final m = EcoStatsModel.fromJson(fullStatsJson());
      expect(m.milestones, hasLength(2));
    });

    test('empty milestones list', () {
      final json = {...fullStatsJson(), 'milestones': <dynamic>[]};
      expect(EcoStatsModel.fromJson(json).milestones, isEmpty);
    });

    test('null milestones defaults to empty list', () {
      final json = Map<String, dynamic>.from(fullStatsJson())..remove('milestones');
      expect(EcoStatsModel.fromJson(json).milestones, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────────────
  // EcoStatsModel.fromJson — camelCase fallback
  // ─────────────────────────────────────────────────────────
  group('EcoStatsModel.fromJson camelCase fallback', () {
    Map<String, dynamic> camelJson() => {
          'userId': 'u2',
          'totalPoints': 200,
          'totalWeightRecycled': 5.0,
          'itemsSold': 2,
          'pickupsCompleted': 3,
          'co2Reduced': 4.0,
          'currentBadge': 'bronze',
          'currentStreak': 2,
          'longestStreak': 5,
          'lastActivityDate': lastActivity.toIso8601String(),
          'milestones': <dynamic>[],
        };

    test('userId via camelCase', () {
      expect(EcoStatsModel.fromJson(camelJson()).userId, 'u2');
    });
    test('totalPoints via camelCase', () {
      expect(EcoStatsModel.fromJson(camelJson()).totalPoints, 200);
    });
    test('totalWeightRecycled via camelCase', () {
      expect(EcoStatsModel.fromJson(camelJson()).totalWeightRecycled, 5.0);
    });
    test('currentBadge via camelCase', () {
      expect(EcoStatsModel.fromJson(camelJson()).currentBadge, EcoBadgeType.bronze);
    });
    test('currentStreak via camelCase', () {
      expect(EcoStatsModel.fromJson(camelJson()).currentStreak, 2);
    });
    test('lastActivityDate via camelCase', () {
      expect(EcoStatsModel.fromJson(camelJson()).lastActivityDate, lastActivity);
    });
  });

  // ─────────────────────────────────────────────────────────
  // Numeric defaults
  // ─────────────────────────────────────────────────────────
  group('EcoStatsModel defaults', () {
    Map<String, dynamic> bareJson() => {
          'user_id': 'u3',
          'last_activity_date': lastActivity.toIso8601String(),
        };

    test('totalPoints defaults to 0', () {
      expect(EcoStatsModel.fromJson(bareJson()).totalPoints, 0);
    });
    test('totalWeightRecycled defaults to 0.0', () {
      expect(EcoStatsModel.fromJson(bareJson()).totalWeightRecycled, 0.0);
    });
    test('itemsSold defaults to 0', () {
      expect(EcoStatsModel.fromJson(bareJson()).itemsSold, 0);
    });
    test('pickupsCompleted defaults to 0', () {
      expect(EcoStatsModel.fromJson(bareJson()).pickupsCompleted, 0);
    });
    test('co2Reduced defaults to 0.0', () {
      expect(EcoStatsModel.fromJson(bareJson()).co2Reduced, 0.0);
    });
    test('currentBadge defaults to beginner', () {
      expect(EcoStatsModel.fromJson(bareJson()).currentBadge, EcoBadgeType.beginner);
    });
    test('currentStreak defaults to 0', () {
      expect(EcoStatsModel.fromJson(bareJson()).currentStreak, 0);
    });
    test('longestStreak defaults to 0', () {
      expect(EcoStatsModel.fromJson(bareJson()).longestStreak, 0);
    });
  });

  // ─────────────────────────────────────────────────────────
  // Badge parsing
  // ─────────────────────────────────────────────────────────
  group('EcoStatsModel badge parsing', () {
    const table = {
      'beginner': EcoBadgeType.beginner,
      'bronze': EcoBadgeType.bronze,
      'silver': EcoBadgeType.silver,
      'gold': EcoBadgeType.gold,
      'platinum': EcoBadgeType.platinum,
      'champion': EcoBadgeType.champion,
    };
    for (final entry in table.entries) {
      test('"${entry.key}" → ${entry.value}', () {
        final json = {...fullStatsJson(), 'current_badge': entry.key};
        expect(EcoStatsModel.fromJson(json).currentBadge, entry.value);
      });
    }

    test('unknown badge defaults to beginner', () {
      final json = {...fullStatsJson(), 'current_badge': 'legendary'};
      expect(EcoStatsModel.fromJson(json).currentBadge, EcoBadgeType.beginner);
    });

    test('badge is case-insensitive', () {
      final json = {...fullStatsJson(), 'current_badge': 'GOLD'};
      expect(EcoStatsModel.fromJson(json).currentBadge, EcoBadgeType.gold);
    });
  });

  // ─────────────────────────────────────────────────────────
  // Numeric casting (int → double)
  // ─────────────────────────────────────────────────────────
  group('EcoStatsModel numeric casting', () {
    test('totalWeightRecycled as int casts to double', () {
      final json = {...fullStatsJson(), 'total_weight_recycled': 10};
      expect(EcoStatsModel.fromJson(json).totalWeightRecycled, 10.0);
      expect(EcoStatsModel.fromJson(json).totalWeightRecycled, isA<double>());
    });

    test('co2Reduced as int casts to double', () {
      final json = {...fullStatsJson(), 'co2_reduced': 5};
      expect(EcoStatsModel.fromJson(json).co2Reduced, 5.0);
      expect(EcoStatsModel.fromJson(json).co2Reduced, isA<double>());
    });
  });

  // ─────────────────────────────────────────────────────────
  // toJson
  // ─────────────────────────────────────────────────────────
  group('EcoStatsModel.toJson', () {
    test('produces all expected snake_case keys', () {
      final j = EcoStatsModel.fromJson(fullStatsJson()).toJson();
      for (final key in [
        'user_id', 'total_points', 'total_weight_recycled', 'items_sold',
        'pickups_completed', 'co2_reduced', 'current_badge', 'current_streak',
        'longest_streak', 'last_activity_date', 'milestones',
      ]) {
        expect(j.containsKey(key), isTrue, reason: 'Missing key: $key');
      }
    });

    test('current_badge serialises as enum name', () {
      final m = EcoStatsModel.fromJson(fullStatsJson());
      expect(m.toJson()['current_badge'], 'silver');
    });

    test('milestones serialises as list of maps', () {
      final j = EcoStatsModel.fromJson(fullStatsJson()).toJson();
      expect(j['milestones'], isA<List>());
      expect((j['milestones'] as List).length, 2);
    });

    test('milestone map has all expected keys', () {
      final j = EcoStatsModel.fromJson(fullStatsJson()).toJson();
      final m = (j['milestones'] as List).first as Map<String, dynamic>;
      for (final key in ['id', 'title', 'description', 'required_points', 'is_achieved', 'achieved_at']) {
        expect(m.containsKey(key), isTrue, reason: 'Milestone missing key: $key');
      }
    });

    test('achieved_at is null in toJson for unachieved milestone', () {
      final json = {...fullStatsJson(), 'milestones': [milestoneJson(achieved: false)]};
      final j = EcoStatsModel.fromJson(json).toJson();
      final m = (j['milestones'] as List).first as Map<String, dynamic>;
      expect(m['achieved_at'], isNull);
    });

    test('totalPoints serialises as int', () {
      final j = EcoStatsModel.fromJson(fullStatsJson()).toJson();
      expect(j['total_points'], isA<int>());
    });
  });

  // ─────────────────────────────────────────────────────────
  // Round-trip
  // ─────────────────────────────────────────────────────────
  group('EcoStatsModel round-trip', () {
    test('full stats object survives fromJson → toJson → fromJson', () {
      final original = EcoStatsModel.fromJson(fullStatsJson());
      final roundTripped = EcoStatsModel.fromJson(original.toJson());
      expect(roundTripped, equals(original));
    });

    test('all badge values survive round-trip', () {
      for (final badge in EcoBadgeType.values) {
        final json = {...fullStatsJson(), 'current_badge': badge.name};
        final original = EcoStatsModel.fromJson(json);
        final roundTripped = EcoStatsModel.fromJson(original.toJson());
        expect(roundTripped.currentBadge, badge);
      }
    });
  });

  // ─────────────────────────────────────────────────────────
  // EcoMilestoneModel
  // ─────────────────────────────────────────────────────────
  group('EcoMilestoneModel.fromJson', () {
    test('parses all fields when achieved', () {
      final m = EcoMilestoneModel.fromJson(milestoneJson());
      expect(m.id, 'm1');
      expect(m.title, 'First Pickup');
      expect(m.description, 'Complete your first pickup');
      expect(m.requiredPoints, 10);
      expect(m.isAchieved, isTrue);
      expect(m.achievedAt, achievedAt);
    });

    test('achievedAt is null when not achieved', () {
      final m = EcoMilestoneModel.fromJson(milestoneJson(achieved: false));
      expect(m.isAchieved, isFalse);
      expect(m.achievedAt, isNull);
    });

    test('requiredPoints defaults to 0 when absent', () {
      final json = {
        'id': 'm2',
        'title': 'T',
        'description': 'D',
        'is_achieved': false,
      };
      expect(EcoMilestoneModel.fromJson(json).requiredPoints, 0);
    });

    test('isAchieved defaults to false when absent', () {
      final json = {
        'id': 'm3',
        'title': 'T',
        'description': 'D',
        'required_points': 5,
      };
      expect(EcoMilestoneModel.fromJson(json).isAchieved, isFalse);
    });

    test('camelCase requiredPoints key', () {
      final json = {
        'id': 'm4',
        'title': 'T',
        'description': 'D',
        'requiredPoints': 50,
        'isAchieved': true,
        'achievedAt': achievedAt.toIso8601String(),
      };
      final m = EcoMilestoneModel.fromJson(json);
      expect(m.requiredPoints, 50);
      expect(m.isAchieved, isTrue);
      expect(m.achievedAt, achievedAt);
    });

    test('EcoMilestoneModel is a EcoMilestone', () {
      expect(EcoMilestoneModel.fromJson(milestoneJson()), isA<EcoMilestone>());
    });
  });

  // ─────────────────────────────────────────────────────────
  // PointHistoryModel
  // ─────────────────────────────────────────────────────────
  group('PointHistoryModel', () {
    final date = DateTime.utc(2024, 4, 1, 12, 0, 0);

    Map<String, dynamic> pointJson() => {
          'id': 'ph1',
          'points': 25,
          'reason': 'Completed pickup',
          'date': date.toIso8601String(),
          'related_id': 'pr42',
        };

    test('fromJson parses all fields', () {
      final m = PointHistoryModel.fromJson(pointJson());
      expect(m.id, 'ph1');
      expect(m.points, 25);
      expect(m.reason, 'Completed pickup');
      expect(m.date, date);
      expect(m.relatedId, 'pr42');
    });

    test('relatedId is null when absent', () {
      final json = Map<String, dynamic>.from(pointJson())..remove('related_id');
      expect(PointHistoryModel.fromJson(json).relatedId, isNull);
    });

    test('date can be parsed from created_at key', () {
      final json = {
        'id': 'ph2',
        'points': 10,
        'reason': 'Sale',
        'created_at': date.toIso8601String(),
      };
      expect(PointHistoryModel.fromJson(json).date, date);
    });

    test('camelCase relatedId key', () {
      final json = {...pointJson()..remove('related_id'), 'relatedId': 'listing-7'};
      expect(PointHistoryModel.fromJson(json).relatedId, 'listing-7');
    });

    group('toJson', () {
      test('produces expected keys', () {
        final j = PointHistoryModel.fromJson(pointJson()).toJson();
        for (final key in ['id', 'points', 'reason', 'date', 'related_id']) {
          expect(j.containsKey(key), isTrue, reason: 'Missing key: $key');
        }
      });

      test('date serialises as ISO-8601', () {
        final j = PointHistoryModel.fromJson(pointJson()).toJson();
        expect(j['date'], date.toIso8601String());
      });

      test('null relatedId serialises as null', () {
        final json = Map<String, dynamic>.from(pointJson())..remove('related_id');
        final j = PointHistoryModel.fromJson(json).toJson();
        expect(j['related_id'], isNull);
      });

      test('points serialises as int', () {
        final j = PointHistoryModel.fromJson(pointJson()).toJson();
        expect(j['points'], isA<int>());
        expect(j['points'], 25);
      });
    });

    test('round-trip fromJson → toJson → fromJson', () {
      final original = PointHistoryModel.fromJson(pointJson());
      final roundTripped = PointHistoryModel.fromJson(original.toJson());
      expect(roundTripped, equals(original));
    });

    test('PointHistoryModel is a PointHistory', () {
      expect(PointHistoryModel.fromJson(pointJson()), isA<PointHistory>());
    });
  });

  // ─────────────────────────────────────────────────────────
  // EcoStatsModel is-a check
  // ─────────────────────────────────────────────────────────
  test('EcoStatsModel is a EcoStats', () {
    expect(EcoStatsModel.fromJson(fullStatsJson()), isA<EcoStats>());
  });
}
