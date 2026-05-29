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
  final double? latitude;
  final double? longitude;
  final String? notes;
  final PickupStatus status;
  final String? collectorId;
  final String? collectorName;
  final String? collectorPhone;
  final String? collectorPhoto;
  final double? collectorRating;
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final PickupTimeSlot? timeSlot;
  final bool isRecurring;
  final RecurrenceFrequency? recurrenceFrequency;
  final int? recurrenceDayOfWeek; // 1=Mon, 7=Sun
  final String? recurringScheduleId;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final int? ecoPointsEarned;
  final int? etaMinutes;
  final double? collectorLatitude;
  final double? collectorLongitude;
  final String? qrToken;
  final double? rating;
  final String? feedback;

  const PickupRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.category,
    required this.estimatedWeight,
    required this.address,
    this.latitude,
    this.longitude,
    this.notes,
    required this.status,
    this.collectorId,
    this.collectorName,
    this.collectorPhone,
    this.collectorPhoto,
    this.collectorRating,
    required this.createdAt,
    this.scheduledDate,
    this.timeSlot,
    this.isRecurring = false,
    this.recurrenceFrequency,
    this.recurrenceDayOfWeek,
    this.recurringScheduleId,
    this.acceptedAt,
    this.completedAt,
    this.ecoPointsEarned,
    this.etaMinutes,
    this.collectorLatitude,
    this.collectorLongitude,
    this.qrToken,
    this.rating,
    this.feedback,
  });

  PickupRequest copyWith({
    String? id,
    String? userId,
    String? userName,
    WasteCategory? category,
    double? estimatedWeight,
    String? address,
    double? latitude,
    double? longitude,
    String? notes,
    PickupStatus? status,
    String? collectorId,
    String? collectorName,
    String? collectorPhone,
    String? collectorPhoto,
    double? collectorRating,
    DateTime? createdAt,
    DateTime? scheduledDate,
    PickupTimeSlot? timeSlot,
    bool? isRecurring,
    RecurrenceFrequency? recurrenceFrequency,
    int? recurrenceDayOfWeek,
    String? recurringScheduleId,
    DateTime? acceptedAt,
    DateTime? completedAt,
    int? ecoPointsEarned,
    int? etaMinutes,
    double? collectorLatitude,
    double? collectorLongitude,
    String? qrToken,
    double? rating,
    String? feedback,
  }) {
    return PickupRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      category: category ?? this.category,
      estimatedWeight: estimatedWeight ?? this.estimatedWeight,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      collectorId: collectorId ?? this.collectorId,
      collectorName: collectorName ?? this.collectorName,
      collectorPhone: collectorPhone ?? this.collectorPhone,
      collectorPhoto: collectorPhoto ?? this.collectorPhoto,
      collectorRating: collectorRating ?? this.collectorRating,
      createdAt: createdAt ?? this.createdAt,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      timeSlot: timeSlot ?? this.timeSlot,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceFrequency: recurrenceFrequency ?? this.recurrenceFrequency,
      recurrenceDayOfWeek: recurrenceDayOfWeek ?? this.recurrenceDayOfWeek,
      recurringScheduleId: recurringScheduleId ?? this.recurringScheduleId,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      ecoPointsEarned: ecoPointsEarned ?? this.ecoPointsEarned,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      collectorLatitude: collectorLatitude ?? this.collectorLatitude,
      collectorLongitude: collectorLongitude ?? this.collectorLongitude,
      qrToken: qrToken ?? this.qrToken,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
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
        latitude,
        longitude,
        notes,
        status,
        collectorId,
        collectorName,
        collectorPhone,
        collectorPhoto,
        collectorRating,
        createdAt,
        scheduledDate,
        timeSlot,
        isRecurring,
        recurrenceFrequency,
        recurrenceDayOfWeek,
        recurringScheduleId,
        acceptedAt,
        completedAt,
        ecoPointsEarned,
        etaMinutes,
        collectorLatitude,
        collectorLongitude,
        qrToken,
        rating,
        feedback,
      ];
}
