import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/pickup/domain/entities/pickup_request.dart';
import 'package:felo_na/features/pickup/domain/repositories/pickup_repository.dart';

/// Creates a new pickup request (one-time or recurring).
class CreatePickupUseCase extends UseCase<PickupRequest, CreatePickupParams> {
  final PickupRepository repository;

  CreatePickupUseCase(this.repository);

  @override
  Future<Either<Failure, PickupRequest>> call(CreatePickupParams params) =>
      repository.createPickup(
        category: params.category,
        estimatedWeight: params.estimatedWeight,
        address: params.address,
        latitude: params.latitude,
        longitude: params.longitude,
        notes: params.notes,
        scheduledDate: params.scheduledDate,
        timeSlot: params.timeSlot,
        isRecurring: params.isRecurring,
        recurrenceFrequency: params.recurrenceFrequency,
        recurrenceDayOfWeek: params.recurrenceDayOfWeek,
      );
}

class CreatePickupParams extends Equatable {
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

  const CreatePickupParams({
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
