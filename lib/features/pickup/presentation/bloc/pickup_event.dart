import 'package:equatable/equatable.dart';
import 'package:felo_na/core/constants/enums.dart';

/// Base class for all pickup events.
abstract class PickupEvent extends Equatable {
  const PickupEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all pickup requests.
class LoadPickupsRequested extends PickupEvent {
  const LoadPickupsRequested();
}

/// Event to create a new pickup request with scheduling.
class CreatePickupRequested extends PickupEvent {
  final WasteCategory category;
  final double estimatedWeight;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? notes;
  final DateTime? scheduledDate;
  final PickupTimeSlot? timeSlot;
  final bool isRecurring;
  final RecurrenceFrequency? recurrenceFrequency;
  final int? recurrenceDayOfWeek;

  const CreatePickupRequested({
    required this.category,
    required this.estimatedWeight,
    required this.address,
    this.latitude,
    this.longitude,
    this.notes,
    this.scheduledDate,
    this.timeSlot,
    this.isRecurring = false,
    this.recurrenceFrequency,
    this.recurrenceDayOfWeek,
  });

  @override
  List<Object?> get props => [
        category,
        estimatedWeight,
        address,
        latitude,
        longitude,
        notes,
        scheduledDate,
        timeSlot,
        isRecurring,
        recurrenceFrequency,
        recurrenceDayOfWeek,
      ];
}

/// Event to load a single pickup by ID.
class LoadPickupDetailRequested extends PickupEvent {
  final String pickupId;

  const LoadPickupDetailRequested({required this.pickupId});

  @override
  List<Object?> get props => [pickupId];
}

/// Event to accept a pickup request (for collectors).
class AcceptPickupRequested extends PickupEvent {
  final String pickupId;

  const AcceptPickupRequested({required this.pickupId});

  @override
  List<Object?> get props => [pickupId];
}

/// Event to update pickup status.
class UpdatePickupStatusRequested extends PickupEvent {
  final String pickupId;
  final PickupStatus newStatus;

  const UpdatePickupStatusRequested({
    required this.pickupId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [pickupId, newStatus];
}

/// Event to complete a pickup.
class CompletePickupRequested extends PickupEvent {
  final String pickupId;

  const CompletePickupRequested({required this.pickupId});

  @override
  List<Object?> get props => [pickupId];
}

/// Event to load pickup history with pagination.
class LoadPickupHistoryRequested extends PickupEvent {
  final int page;
  final int limit;

  const LoadPickupHistoryRequested({this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [page, limit];
}

/// Event to rate a completed pickup.
class RatePickupRequested extends PickupEvent {
  final String pickupId;
  final double rating;
  final String? feedback;

  const RatePickupRequested({
    required this.pickupId,
    required this.rating,
    this.feedback,
  });

  @override
  List<Object?> get props => [pickupId, rating, feedback];
}

/// Event to verify pickup via QR code.
class VerifyPickupQrRequested extends PickupEvent {
  final String pickupId;
  final String qrToken;

  const VerifyPickupQrRequested({
    required this.pickupId,
    required this.qrToken,
  });

  @override
  List<Object?> get props => [pickupId, qrToken];
}

/// Event to refresh live tracking data.
class RefreshTrackingRequested extends PickupEvent {
  final String pickupId;

  const RefreshTrackingRequested({required this.pickupId});

  @override
  List<Object?> get props => [pickupId];
}

/// Event to cancel a recurring schedule.
class CancelRecurringScheduleRequested extends PickupEvent {
  final String scheduleId;

  const CancelRecurringScheduleRequested({required this.scheduleId});

  @override
  List<Object?> get props => [scheduleId];
}
