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

/// Event to create a new pickup request.
class CreatePickupRequested extends PickupEvent {
  final WasteCategory category;
  final double estimatedWeight;
  final String address;
  final String? notes;

  const CreatePickupRequested({
    required this.category,
    required this.estimatedWeight,
    required this.address,
    this.notes,
  });

  @override
  List<Object?> get props => [category, estimatedWeight, address, notes];
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
