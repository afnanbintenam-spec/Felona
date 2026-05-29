import 'package:dartz/dartz.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/errors/error_handler.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/pickup/data/datasources/pickup_remote_data_source.dart';
import 'package:felo_na/features/pickup/domain/entities/pickup_request.dart';
import 'package:felo_na/features/pickup/domain/repositories/pickup_repository.dart';

class PickupRepositoryImpl implements PickupRepository {
  final PickupRemoteDataSource _remoteDataSource;

  PickupRepositoryImpl({required PickupRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<PickupRequest>>> getPickups() async {
    try {
      final pickups = await _remoteDataSource.getPickups();
      return Right(pickups);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, PickupRequest>> createPickup({
    required WasteCategory category,
    required double estimatedWeight,
    required String address,
    double? latitude,
    double? longitude,
    String? notes,
    DateTime? scheduledDate,
    PickupTimeSlot? timeSlot,
    bool isRecurring = false,
    RecurrenceFrequency? recurrenceFrequency,
    int? recurrenceDayOfWeek,
  }) async {
    try {
      final pickup = await _remoteDataSource.createPickup(
        category: category,
        estimatedWeight: estimatedWeight,
        address: address,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
        scheduledDate: scheduledDate,
        timeSlot: timeSlot,
        isRecurring: isRecurring,
        recurrenceFrequency: recurrenceFrequency,
        recurrenceDayOfWeek: recurrenceDayOfWeek,
      );
      return Right(pickup);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, PickupRequest>> getPickupById(String pickupId) async {
    try {
      final pickup = await _remoteDataSource.getPickupById(pickupId);
      return Right(pickup);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, PickupRequest>> acceptPickup(String pickupId) async {
    try {
      final pickup = await _remoteDataSource.acceptPickup(pickupId);
      return Right(pickup);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, PickupRequest>> updatePickupStatus(
      String pickupId, PickupStatus status) async {
    try {
      final pickup =
          await _remoteDataSource.updatePickupStatus(pickupId, status);
      return Right(pickup);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, PickupRequest>> completePickup(String pickupId) async {
    try {
      final pickup = await _remoteDataSource.completePickup(pickupId);
      return Right(pickup);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<PickupRequest>>> getAvailablePickups() async {
    try {
      final pickups = await _remoteDataSource.getAvailablePickups();
      return Right(pickups);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<PickupRequest>>> getMyPickupHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final pickups =
          await _remoteDataSource.getMyPickupHistory(page: page, limit: limit);
      return Right(pickups);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, PickupRequest>> ratePickup({
    required String pickupId,
    required double rating,
    String? feedback,
  }) async {
    try {
      final pickup = await _remoteDataSource.ratePickup(
        pickupId: pickupId,
        rating: rating,
        feedback: feedback,
      );
      return Right(pickup);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, PickupRequest>> verifyPickupQr({
    required String pickupId,
    required String qrToken,
  }) async {
    try {
      final pickup = await _remoteDataSource.verifyPickupQr(
        pickupId: pickupId,
        qrToken: qrToken,
      );
      return Right(pickup);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, PickupRequest>> getPickupTracking(
      String pickupId) async {
    try {
      final pickup = await _remoteDataSource.getPickupTracking(pickupId);
      return Right(pickup);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> cancelRecurringSchedule(
      String scheduleId) async {
    try {
      await _remoteDataSource.cancelRecurringSchedule(scheduleId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler.handleException(e));
    }
  }
}
