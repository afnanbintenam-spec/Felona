import 'package:dartz/dartz.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/pickup/domain/entities/pickup_request.dart';

/// Repository interface for pickup operations.
abstract class PickupRepository {
  Future<Either<Failure, List<PickupRequest>>> getPickups();

  Future<Either<Failure, PickupRequest>> createPickup({
    required WasteCategory category,
    required double estimatedWeight,
    required String address,
    double? latitude,
    double? longitude,
    String? notes,
    DateTime? scheduledDate,
    PickupTimeSlot? timeSlot,
    bool isRecurring,
    RecurrenceFrequency? recurrenceFrequency,
    int? recurrenceDayOfWeek,
  });

  Future<Either<Failure, PickupRequest>> getPickupById(String pickupId);

  Future<Either<Failure, PickupRequest>> acceptPickup(String pickupId);

  Future<Either<Failure, PickupRequest>> updatePickupStatus(
      String pickupId, PickupStatus status);

  Future<Either<Failure, PickupRequest>> completePickup(String pickupId);

  Future<Either<Failure, List<PickupRequest>>> getAvailablePickups();

  Future<Either<Failure, List<PickupRequest>>> getMyPickupHistory({
    int page,
    int limit,
  });

  /// Rate a completed pickup.
  Future<Either<Failure, PickupRequest>> ratePickup({
    required String pickupId,
    required double rating,
    String? feedback,
  });

  /// Verify pickup completion via QR code.
  Future<Either<Failure, PickupRequest>> verifyPickupQr({
    required String pickupId,
    required String qrToken,
  });

  /// Get live tracking data for a pickup.
  Future<Either<Failure, PickupRequest>> getPickupTracking(String pickupId);

  /// Cancel a recurring schedule.
  Future<Either<Failure, void>> cancelRecurringSchedule(String scheduleId);
}
