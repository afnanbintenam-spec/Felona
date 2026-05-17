import 'package:equatable/equatable.dart';
import 'package:felo_na/core/constants/enums.dart';

/// Pickup request entity representing a waste collection request.
///
/// This is a domain entity for pickup requests in the system.
class PickupRequest extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final WasteCategory category;
  final double estimatedWeight; // in kg
  final String address;
  final String? notes;
  final PickupStatus status;
  final String? collectorId;
  final String? collectorName;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final int? ecoPointsEarned;

  const PickupRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.category,
    required this.estimatedWeight,
    required this.address,
    this.notes,
    required this.status,
    this.collectorId,
    this.collectorName,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.ecoPointsEarned,
  });

  PickupRequest copyWith({
    String? id,
    String? userId,
    String? userName,
    WasteCategory? category,
    double? estimatedWeight,
    String? address,
    String? notes,
    PickupStatus? status,
    String? collectorId,
    String? collectorName,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
    int? ecoPointsEarned,
  }) {
    return PickupRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      category: category ?? this.category,
      estimatedWeight: estimatedWeight ?? this.estimatedWeight,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      collectorId: collectorId ?? this.collectorId,
      collectorName: collectorName ?? this.collectorName,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      ecoPointsEarned: ecoPointsEarned ?? this.ecoPointsEarned,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        category,
        estimatedWeight,
        address,
        notes,
        status,
        collectorId,
        collectorName,
        createdAt,
        acceptedAt,
        completedAt,
        ecoPointsEarned,
      ];
}
