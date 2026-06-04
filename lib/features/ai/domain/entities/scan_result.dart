import 'package:equatable/equatable.dart';

/// Domain entity for an AI waste scan result.
///
/// Contains the classification, eco impact, and recommended action
/// returned by the backend /ai/scan endpoint.
class ScanResult extends Equatable {
  final String category;
  final String itemName;
  final String material;
  final String isRecyclable; // "yes" | "partially" | "no"
  final String disposalMethod;
  final String dangerLevel;
  final String ecoTip;
  final String recommendedAction; // "recycle" | "sell" | "pickup" | "dispose"
  final String recommendationReason;
  final int pointsEarned;
  final double co2SavedKg;
  final double landfillSavedKg;
  final double estimatedWeightKg;
  final double confidence;
  final Map<String, dynamic>? estimatedValue; // {min, max} in BDT

  const ScanResult({
    required this.category,
    required this.itemName,
    required this.material,
    required this.isRecyclable,
    required this.disposalMethod,
    required this.dangerLevel,
    required this.ecoTip,
    required this.recommendedAction,
    required this.recommendationReason,
    required this.pointsEarned,
    required this.co2SavedKg,
    required this.landfillSavedKg,
    required this.estimatedWeightKg,
    required this.confidence,
    this.estimatedValue,
  });

  bool get recyclable => isRecyclable.toLowerCase() == 'yes';
  bool get partiallyRecyclable => isRecyclable.toLowerCase() == 'partially';

  @override
  List<Object?> get props => [
        category,
        itemName,
        material,
        isRecyclable,
        disposalMethod,
        dangerLevel,
        ecoTip,
        recommendedAction,
        recommendationReason,
        pointsEarned,
        co2SavedKg,
        landfillSavedKg,
        estimatedWeightKg,
        confidence,
        estimatedValue,
      ];
}
