import 'package:felo_na/features/ai/domain/entities/scan_result.dart';

/// Data model that maps the raw JSON from /ai/scan to [ScanResult].
class ScanResultModel extends ScanResult {
  const ScanResultModel({
    required super.category,
    required super.itemName,
    required super.material,
    required super.isRecyclable,
    required super.disposalMethod,
    required super.dangerLevel,
    required super.ecoTip,
    required super.recommendedAction,
    required super.recommendationReason,
    required super.pointsEarned,
    required super.co2SavedKg,
    required super.landfillSavedKg,
    required super.estimatedWeightKg,
    required super.confidence,
    super.estimatedValue,
  });

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      category: json['category'] as String? ?? 'Unknown',
      itemName: json['item_name'] as String? ?? 'Unknown item',
      material: json['material'] as String? ?? 'Unknown',
      isRecyclable: json['is_recyclable'] as String? ?? 'no',
      disposalMethod: json['disposal_method'] as String? ?? '',
      dangerLevel: json['danger_level'] as String? ?? 'none',
      ecoTip: json['eco_tip'] as String? ?? '',
      recommendedAction: json['recommended_action'] as String? ?? 'dispose',
      recommendationReason: json['recommendation_reason'] as String? ?? '',
      pointsEarned: _toInt(json['points_earned']),
      co2SavedKg: _toDouble(json['co2_saved_kg']),
      landfillSavedKg: _toDouble(json['landfill_saved_kg']),
      estimatedWeightKg: _toDouble(json['estimated_weight_kg']),
      confidence: _toDouble(json['confidence']),
      estimatedValue: json['estimated_value'] as Map<String, dynamic>?,
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
