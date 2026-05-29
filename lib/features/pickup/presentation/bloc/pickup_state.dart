import 'package:equatable/equatable.dart';
import 'package:felo_na/features/pickup/domain/entities/pickup_request.dart';

/// Base class for all pickup states.
abstract class PickupState extends Equatable {
  const PickupState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class PickupInitial extends PickupState {
  const PickupInitial();
}

/// Loading state.
class PickupLoading extends PickupState {
  const PickupLoading();
}

/// Loaded state with pickup requests.
class PickupLoaded extends PickupState {
  final List<PickupRequest> pickups;

  const PickupLoaded({required this.pickups});

  @override
  List<Object?> get props => [pickups];
}

/// Error state.
class PickupError extends PickupState {
  final String message;

  const PickupError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Creating pickup state.
class CreatingPickup extends PickupState {
  const CreatingPickup();
}

/// Pickup created successfully.
class PickupCreated extends PickupState {
  final PickupRequest pickup;

  const PickupCreated({required this.pickup});

  @override
  List<Object?> get props => [pickup];
}

/// Pickup status updated.
class PickupStatusUpdated extends PickupState {
  final PickupRequest pickup;

  const PickupStatusUpdated({required this.pickup});

  @override
  List<Object?> get props => [pickup];
}

/// Pickup detail loaded.
class PickupDetailLoaded extends PickupState {
  final PickupRequest pickup;

  const PickupDetailLoaded({required this.pickup});

  @override
  List<Object?> get props => [pickup];
}

/// Pickup history loaded with pagination.
class PickupHistoryLoaded extends PickupState {
  final List<PickupRequest> pickups;
  final int currentPage;
  final bool hasMore;

  const PickupHistoryLoaded({
    required this.pickups,
    this.currentPage = 1,
    this.hasMore = true,
  });

  @override
  List<Object?> get props => [pickups, currentPage, hasMore];
}

/// Pickup rated successfully.
class PickupRated extends PickupState {
  final PickupRequest pickup;

  const PickupRated({required this.pickup});

  @override
  List<Object?> get props => [pickup];
}

/// QR verification successful.
class PickupQrVerified extends PickupState {
  final PickupRequest pickup;

  const PickupQrVerified({required this.pickup});

  @override
  List<Object?> get props => [pickup];
}

/// Live tracking data updated.
class PickupTrackingUpdated extends PickupState {
  final PickupRequest pickup;

  const PickupTrackingUpdated({required this.pickup});

  @override
  List<Object?> get props => [pickup];
}

/// Recurring schedule cancelled.
class RecurringScheduleCancelled extends PickupState {
  const RecurringScheduleCancelled();
}
