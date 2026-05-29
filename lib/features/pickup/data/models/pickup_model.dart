import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/features/pickup/domain/entities/pickup_request.dart';

/// Data model for PickupRequest with JSON serialization.
class PickupModel extends PickupRequest {
  const PickupModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.category,
    required super.estimatedWeight,
    required super.address,
    super.latitude,
    super.longitude,
    super.notes,
    required super.status,
    super.collectorId,
    super.collectorName,
    super.collectorPhone,
    super.collectorPhoto,
    super.collectorRating,
    required super.createdAt,
    super.scheduledDate,
    super.timeSlot,
    super.isRecurring,
    super.recurrenceFrequency,
    super.recurrenceDayOfWeek,
    super.recurringScheduleId,
    super.acceptedAt,
    super.completedAt,
    super.ecoPointsEarned,
    super.etaMinutes,
    super.collectorLatitude,
    super.collectorLongitude,
    super.qrToken,
    super.rating,
    super.feedback,
  });

  factory PickupModel.fromJson(Map<String, dynamic> json) {
    return PickupModel(
      id: json['id'] as String,
      userId: (json['user_id'] ?? json['userId'] ?? '') as String,
      userName: (json['user_name'] ?? json['userName'] ?? '') as String,
      category: _parseCategory(json['category'] as String? ?? 'other'),
      estimatedWeight: (json['estimated_weight'] ?? json['estimatedWeight'] ?? 0 as num).toDouble(),
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      status: _parseStatus(json['status'] as String? ?? 'pending'),
      collectorId: (json['collector_id'] ?? json['collectorId']) as String?,
      collectorName: (json['collector_name'] ?? json['collectorName']) as String?,
      collectorPhone: (json['collector_phone'] ?? json['collectorPhone']) as String?,
      collectorPhoto: (json['collector_photo'] ?? json['collectorPhoto']) as String?,
      collectorRating: (json['collector_rating'] ?? json['collectorRating'] as num?)?.toDouble(),
      createdAt: DateTime.parse(
        (json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()) as String,
      ),
      scheduledDate: (json['scheduled_date'] ?? json['scheduledDate']) != null
          ? DateTime.parse((json['scheduled_date'] ?? json['scheduledDate']) as String)
          : null,
      timeSlot: json['time_slot'] != null || json['timeSlot'] != null
          ? PickupTimeSlot.fromApiValue((json['time_slot'] ?? json['timeSlot']) as String)
          : null,
      isRecurring: (json['is_recurring'] ?? json['isRecurring'] ?? false) as bool,
      recurrenceFrequency: (json['recurrence_frequency'] ?? json['recurrenceFrequency']) != null
          ? _parseRecurrenceFrequency((json['recurrence_frequency'] ?? json['recurrenceFrequency']) as String)
          : null,
      recurrenceDayOfWeek: (json['recurrence_day'] ?? json['recurrenceDayOfWeek']) as int?,
      recurringScheduleId: (json['recurring_schedule_id'] ?? json['recurringScheduleId']) as String?,
      acceptedAt: (json['accepted_at'] ?? json['acceptedAt']) != null
          ? DateTime.parse((json['accepted_at'] ?? json['acceptedAt']) as String)
          : null,
      completedAt: (json['completed_at'] ?? json['completedAt']) != null
          ? DateTime.parse((json['completed_at'] ?? json['completedAt']) as String)
          : null,
      ecoPointsEarned: (json['eco_points_earned'] ?? json['ecoPointsEarned']) as int?,
      etaMinutes: (json['eta_minutes'] ?? json['etaMinutes']) as int?,
      collectorLatitude: (json['collector_latitude'] ?? json['collectorLatitude'] as num?)?.toDouble(),
      collectorLongitude: (json['collector_longitude'] ?? json['collectorLongitude'] as num?)?.toDouble(),
      qrToken: (json['qr_token'] ?? json['qrToken']) as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      feedback: json['feedback'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'category': category.name,
      'estimated_weight': estimatedWeight,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
      'status': _statusToString(status),
      'collector_id': collectorId,
      'collector_name': collectorName,
      'collector_phone': collectorPhone,
      'collector_photo': collectorPhoto,
      'collector_rating': collectorRating,
      'created_at': createdAt.toIso8601String(),
      'scheduled_date': scheduledDate?.toIso8601String(),
      'time_slot': timeSlot?.apiValue,
      'is_recurring': isRecurring,
      'recurrence_frequency': recurrenceFrequency?.name,
      'recurrence_day': recurrenceDayOfWeek,
      'recurring_schedule_id': recurringScheduleId,
      'accepted_at': acceptedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'eco_points_earned': ecoPointsEarned,
      'eta_minutes': etaMinutes,
      'collector_latitude': collectorLatitude,
      'collector_longitude': collectorLongitude,
      'qr_token': qrToken,
      'rating': rating,
      'feedback': feedback,
    };
  }

  static WasteCategory _parseCategory(String value) {
    switch (value.toLowerCase()) {
      case 'plastic':
        return WasteCategory.plastic;
      case 'metal':
        return WasteCategory.metal;
      case 'paper':
        return WasteCategory.paper;
      case 'glass':
        return WasteCategory.glass;
      case 'electronics':
        return WasteCategory.electronics;
      default:
        return WasteCategory.other;
    }
  }

  static PickupStatus _parseStatus(String value) {
    switch (value.toLowerCase().replaceAll('_', '')) {
      case 'pending':
        return PickupStatus.pending;
      case 'assigned':
        return PickupStatus.assigned;
      case 'accepted':
        return PickupStatus.accepted;
      case 'ontheway':
      case 'on_the_way':
        return PickupStatus.onTheWay;
      case 'arrived':
        return PickupStatus.arrived;
      case 'completed':
        return PickupStatus.completed;
      case 'cancelled':
        return PickupStatus.cancelled;
      default:
        return PickupStatus.pending;
    }
  }

  static RecurrenceFrequency _parseRecurrenceFrequency(String value) {
    switch (value.toLowerCase()) {
      case 'biweekly':
        return RecurrenceFrequency.biweekly;
      default:
        return RecurrenceFrequency.weekly;
    }
  }

  static String _statusToString(PickupStatus status) {
    switch (status) {
      case PickupStatus.pending:
        return 'pending';
      case PickupStatus.assigned:
        return 'assigned';
      case PickupStatus.accepted:
        return 'accepted';
      case PickupStatus.onTheWay:
        return 'on_the_way';
      case PickupStatus.arrived:
        return 'arrived';
      case PickupStatus.completed:
        return 'completed';
      case PickupStatus.cancelled:
        return 'cancelled';
    }
  }
}
