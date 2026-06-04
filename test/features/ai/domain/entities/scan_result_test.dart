import 'package:flutter_test/flutter_test.dart';
import 'package:felo_na/features/ai/domain/entities/scan_result.dart';

void main() {
  // ─────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────
  ScanResult makeBase({
    String isRecyclable = 'yes',
    String recommendedAction = 'recycle',
    int pointsEarned = 20,
    double co2SavedKg = 1.5,
    double landfillSavedKg = 0.8,
    double estimatedWeightKg = 0.5,
    double confidence = 0.95,
    Map<String, dynamic>? estimatedValue,
  }) =>
      ScanResult(
        category: 'plastic',
        itemName: 'PET Bottle',
        material: 'PET Plastic',
        isRecyclable: isRecyclable,
        disposalMethod: 'Recycling bin',
        dangerLevel: 'low',
        ecoTip: 'Rinse before recycling',
        recommendedAction: recommendedAction,
        recommendationReason: 'High recyclability',
        pointsEarned: pointsEarned,
        co2SavedKg: co2SavedKg,
        landfillSavedKg: landfillSavedKg,
        estimatedWeightKg: estimatedWeightKg,
        confidence: confidence,
        estimatedValue: estimatedValue,
      );

  // ─────────────────────────────────────────────────────────
  // Construction & field access
  // ─────────────────────────────────────────────────────────
  group('ScanResult construction', () {
    test('fields are stored correctly', () {
      final r = makeBase();
      expect(r.category, 'plastic');
      expect(r.itemName, 'PET Bottle');
      expect(r.material, 'PET Plastic');
      expect(r.isRecyclable, 'yes');
      expect(r.disposalMethod, 'Recycling bin');
      expect(r.dangerLevel, 'low');
      expect(r.ecoTip, 'Rinse before recycling');
      expect(r.recommendedAction, 'recycle');
      expect(r.recommendationReason, 'High recyclability');
      expect(r.pointsEarned, 20);
      expect(r.co2SavedKg, 1.5);
      expect(r.landfillSavedKg, 0.8);
      expect(r.estimatedWeightKg, 0.5);
      expect(r.confidence, 0.95);
      expect(r.estimatedValue, isNull);
    });

    test('estimatedValue map is stored when provided', () {
      final r = makeBase(estimatedValue: {'min': 50, 'max': 150});
      expect(r.estimatedValue, isNotNull);
      expect(r.estimatedValue!['min'], 50);
      expect(r.estimatedValue!['max'], 150);
    });
  });

  // ─────────────────────────────────────────────────────────
  // Computed getters — recyclable / partiallyRecyclable
  // ─────────────────────────────────────────────────────────
  group('recyclable getter', () {
    test('"yes" → recyclable is true', () {
      expect(makeBase(isRecyclable: 'yes').recyclable, isTrue);
    });

    test('"YES" (uppercase) → recyclable is true', () {
      expect(makeBase(isRecyclable: 'YES').recyclable, isTrue);
    });

    test('"Yes" (mixed case) → recyclable is true', () {
      expect(makeBase(isRecyclable: 'Yes').recyclable, isTrue);
    });

    test('"partially" → recyclable is false', () {
      expect(makeBase(isRecyclable: 'partially').recyclable, isFalse);
    });

    test('"no" → recyclable is false', () {
      expect(makeBase(isRecyclable: 'no').recyclable, isFalse);
    });

    test('empty string → recyclable is false', () {
      expect(makeBase(isRecyclable: '').recyclable, isFalse);
    });
  });

  group('partiallyRecyclable getter', () {
    test('"partially" → partiallyRecyclable is true', () {
      expect(makeBase(isRecyclable: 'partially').partiallyRecyclable, isTrue);
    });

    test('"PARTIALLY" (uppercase) → partiallyRecyclable is true', () {
      expect(makeBase(isRecyclable: 'PARTIALLY').partiallyRecyclable, isTrue);
    });

    test('"Partially" (mixed case) → partiallyRecyclable is true', () {
      expect(makeBase(isRecyclable: 'Partially').partiallyRecyclable, isTrue);
    });

    test('"yes" → partiallyRecyclable is false', () {
      expect(makeBase(isRecyclable: 'yes').partiallyRecyclable, isFalse);
    });

    test('"no" → partiallyRecyclable is false', () {
      expect(makeBase(isRecyclable: 'no').partiallyRecyclable, isFalse);
    });

    test('empty string → partiallyRecyclable is false', () {
      expect(makeBase(isRecyclable: '').partiallyRecyclable, isFalse);
    });
  });

  group('recyclable and partiallyRecyclable mutual exclusivity', () {
    test('"yes" → only recyclable', () {
      final r = makeBase(isRecyclable: 'yes');
      expect(r.recyclable, isTrue);
      expect(r.partiallyRecyclable, isFalse);
    });

    test('"partially" → only partiallyRecyclable', () {
      final r = makeBase(isRecyclable: 'partially');
      expect(r.recyclable, isFalse);
      expect(r.partiallyRecyclable, isTrue);
    });

    test('"no" → neither', () {
      final r = makeBase(isRecyclable: 'no');
      expect(r.recyclable, isFalse);
      expect(r.partiallyRecyclable, isFalse);
    });
  });

  // ─────────────────────────────────────────────────────────
  // Equality (Equatable)
  // ─────────────────────────────────────────────────────────
  group('ScanResult equality', () {
    test('same data → equal', () {
      expect(makeBase(), equals(makeBase()));
    });

    test('different itemName → not equal', () {
      expect(makeBase() == makeBase().rebuild(itemName: 'Glass Jar'), isFalse);
    });

    test('different pointsEarned → not equal', () {
      expect(
        makeBase(pointsEarned: 20) == makeBase(pointsEarned: 99),
        isFalse,
      );
    });

    test('different confidence → not equal', () {
      expect(
        makeBase(confidence: 0.95) == makeBase(confidence: 0.5),
        isFalse,
      );
    });

    test('with vs without estimatedValue → not equal', () {
      final withMap = makeBase(estimatedValue: {'min': 10, 'max': 50});
      final withoutMap = makeBase();
      expect(withMap == withoutMap, isFalse);
    });

    test('hashCode is consistent', () {
      expect(makeBase().hashCode, makeBase().hashCode);
    });
  });

  // ─────────────────────────────────────────────────────────
  // Boundary values
  // ─────────────────────────────────────────────────────────
  group('ScanResult boundary cases', () {
    test('pointsEarned can be 0', () {
      expect(makeBase(pointsEarned: 0).pointsEarned, 0);
    });

    test('co2SavedKg can be 0.0', () {
      expect(makeBase(co2SavedKg: 0.0).co2SavedKg, 0.0);
    });

    test('confidence at lower boundary 0.0', () {
      expect(makeBase(confidence: 0.0).confidence, 0.0);
    });

    test('confidence at upper boundary 1.0', () {
      expect(makeBase(confidence: 1.0).confidence, 1.0);
    });

    test('estimatedWeightKg close to zero', () {
      expect(makeBase(estimatedWeightKg: 0.001).estimatedWeightKg, 0.001);
    });

    test('large pointsEarned', () {
      expect(makeBase(pointsEarned: 9999).pointsEarned, 9999);
    });
  });

  group('recommendedAction values', () {
    for (final action in ['recycle', 'sell', 'pickup', 'dispose']) {
      test('"$action" is stored correctly', () {
        expect(makeBase(recommendedAction: action).recommendedAction, action);
      });
    }
  });
}

// ─────────────────────────────────────────────────────────
// ScanResult does not have a copyWith; use an extension
// to rebuild individual fields in tests without modifying prod code.
// ─────────────────────────────────────────────────────────
extension _ScanResultRebuild on ScanResult {
  ScanResult rebuild({
    String? category,
    String? itemName,
    String? material,
    String? isRecyclable,
    String? disposalMethod,
    String? dangerLevel,
    String? ecoTip,
    String? recommendedAction,
    String? recommendationReason,
    int? pointsEarned,
    double? co2SavedKg,
    double? landfillSavedKg,
    double? estimatedWeightKg,
    double? confidence,
    Map<String, dynamic>? estimatedValue,
  }) =>
      ScanResult(
        category: category ?? this.category,
        itemName: itemName ?? this.itemName,
        material: material ?? this.material,
        isRecyclable: isRecyclable ?? this.isRecyclable,
        disposalMethod: disposalMethod ?? this.disposalMethod,
        dangerLevel: dangerLevel ?? this.dangerLevel,
        ecoTip: ecoTip ?? this.ecoTip,
        recommendedAction: recommendedAction ?? this.recommendedAction,
        recommendationReason: recommendationReason ?? this.recommendationReason,
        pointsEarned: pointsEarned ?? this.pointsEarned,
        co2SavedKg: co2SavedKg ?? this.co2SavedKg,
        landfillSavedKg: landfillSavedKg ?? this.landfillSavedKg,
        estimatedWeightKg: estimatedWeightKg ?? this.estimatedWeightKg,
        confidence: confidence ?? this.confidence,
        estimatedValue: estimatedValue ?? this.estimatedValue,
      );
}
