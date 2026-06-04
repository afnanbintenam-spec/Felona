import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:felo_na/core/constants/eco_levels.dart';

void main() {
  // ─────────────────────────────────────────────────────────
  // EcoLevel value object
  // ─────────────────────────────────────────────────────────
  group('EcoLevel', () {
    const seed = EcoLevel(
      name: 'Seed',
      emoji: '🌱',
      minPoints: 0,
      maxPoints: 200,
      color: Color(0xFFA5D6A7),
    );

    test('display returns "name emoji"', () {
      expect(seed.display, 'Seed 🌱');
    });

    group('progressFor', () {
      test('at minPoints returns 0.0', () {
        expect(seed.progressFor(0), 0.0);
      });

      test('at maxPoints returns 1.0', () {
        expect(seed.progressFor(200), 1.0);
      });

      test('above maxPoints clamps to 1.0', () {
        expect(seed.progressFor(999), 1.0);
      });

      test('below minPoints returns 0.0', () {
        // Seed starts at 0 so we cannot go below — use a different level.
        const sprout = EcoLevel(
          name: 'Sprout',
          emoji: '🌿',
          minPoints: 201,
          maxPoints: 500,
          color: Color(0xFF81C784),
        );
        expect(sprout.progressFor(0), 0.0);
      });

      test('midpoint returns 0.5', () {
        // minPoints=0, maxPoints=200 → midpoint at 100
        expect(seed.progressFor(100), 0.5);
      });

      test('one below maxPoints is close to 1.0 but not equal', () {
        final p = seed.progressFor(199);
        expect(p, greaterThan(0.99));
        expect(p, lessThan(1.0));
      });
    });

    group('pointsToNext', () {
      test('at maxPoints returns 0 (already at top of level)', () {
        expect(seed.pointsToNext(200), 0);
      });

      test('above maxPoints returns 0', () {
        expect(seed.pointsToNext(500), 0);
      });

      test('at minPoints returns maxPoints - minPoints + 1', () {
        // 200 - 0 + 1 = 201
        expect(seed.pointsToNext(0), 201);
      });

      test('one below maxPoints returns 2', () {
        expect(seed.pointsToNext(199), 2);
      });
    });
  });

  // ─────────────────────────────────────────────────────────
  // EcoLevels static helpers
  // ─────────────────────────────────────────────────────────
  group('EcoLevels.all', () {
    test('contains exactly 5 levels', () {
      expect(EcoLevels.all.length, 5);
    });

    test('first level is Seed', () {
      expect(EcoLevels.all.first.name, 'Seed');
    });

    test('last level is Earth', () {
      expect(EcoLevels.all.last.name, 'Earth');
    });

    test('levels are in ascending minPoints order', () {
      for (int i = 1; i < EcoLevels.all.length; i++) {
        expect(
          EcoLevels.all[i].minPoints > EcoLevels.all[i - 1].minPoints,
          isTrue,
          reason: '${EcoLevels.all[i].name} must have a higher minPoints than ${EcoLevels.all[i - 1].name}',
        );
      }
    });

    test('every level has a non-empty name and emoji', () {
      for (final level in EcoLevels.all) {
        expect(level.name.isNotEmpty, isTrue);
        expect(level.emoji.isNotEmpty, isTrue);
      }
    });
  });

  group('EcoLevels.fromPoints', () {
    test('0 points → Seed', () {
      expect(EcoLevels.fromPoints(0).name, 'Seed');
    });

    test('200 points → Seed (upper boundary)', () {
      expect(EcoLevels.fromPoints(200).name, 'Seed');
    });

    test('201 points → Sprout', () {
      expect(EcoLevels.fromPoints(201).name, 'Sprout');
    });

    test('500 points → Sprout (upper boundary)', () {
      expect(EcoLevels.fromPoints(500).name, 'Sprout');
    });

    test('501 points → Tree', () {
      expect(EcoLevels.fromPoints(501).name, 'Tree');
    });

    test('1000 points → Tree (upper boundary)', () {
      expect(EcoLevels.fromPoints(1000).name, 'Tree');
    });

    test('1001 points → Forest', () {
      expect(EcoLevels.fromPoints(1001).name, 'Forest');
    });

    test('2000 points → Forest (upper boundary)', () {
      expect(EcoLevels.fromPoints(2000).name, 'Forest');
    });

    test('2001 points → Earth', () {
      expect(EcoLevels.fromPoints(2001).name, 'Earth');
    });

    test('very large points → Earth', () {
      expect(EcoLevels.fromPoints(999999).name, 'Earth');
    });

    test('negative points → Seed (falls back to first)', () {
      // Negative points: no level minPoints ≤ negative, so falls back to all.first
      expect(EcoLevels.fromPoints(-1).name, 'Seed');
    });
  });

  group('EcoLevels.levelNumber', () {
    test('0 points → level 1', () {
      expect(EcoLevels.levelNumber(0), 1);
    });

    test('200 points → level 1', () {
      expect(EcoLevels.levelNumber(200), 1);
    });

    test('201 points → level 2', () {
      expect(EcoLevels.levelNumber(201), 2);
    });

    test('501 points → level 3', () {
      expect(EcoLevels.levelNumber(501), 3);
    });

    test('1001 points → level 4', () {
      expect(EcoLevels.levelNumber(1001), 4);
    });

    test('2001 points → level 5', () {
      expect(EcoLevels.levelNumber(2001), 5);
    });

    test('very large points → level 5', () {
      expect(EcoLevels.levelNumber(1000000), 5);
    });
  });

  group('EcoLevels.nextLevel', () {
    test('Seed (0 pts) → next is Sprout', () {
      expect(EcoLevels.nextLevel(0)?.name, 'Sprout');
    });

    test('Sprout (201 pts) → next is Tree', () {
      expect(EcoLevels.nextLevel(201)?.name, 'Tree');
    });

    test('Tree (501 pts) → next is Forest', () {
      expect(EcoLevels.nextLevel(501)?.name, 'Forest');
    });

    test('Forest (1001 pts) → next is Earth', () {
      expect(EcoLevels.nextLevel(1001)?.name, 'Earth');
    });

    test('Earth (2001 pts) → next is null (max level)', () {
      expect(EcoLevels.nextLevel(2001), isNull);
    });

    test('very large points at max level → null', () {
      expect(EcoLevels.nextLevel(999999), isNull);
    });
  });
}
