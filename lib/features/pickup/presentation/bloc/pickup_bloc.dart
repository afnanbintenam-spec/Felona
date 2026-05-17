import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_event.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_state.dart';
import 'package:felo_na/features/pickup/domain/entities/pickup_request.dart';
import 'package:felo_na/core/constants/enums.dart';

/// BLoC for managing pickup state.
///
/// Handles pickup request operations, status updates, and tracking.
class PickupBloc extends Bloc<PickupEvent, PickupState> {
  PickupBloc() : super(const PickupInitial()) {
    on<LoadPickupsRequested>(_onLoadPickupsRequested);
    on<CreatePickupRequested>(_onCreatePickupRequested);
    on<AcceptPickupRequested>(_onAcceptPickupRequested);
    on<UpdatePickupStatusRequested>(_onUpdatePickupStatusRequested);
    on<CompletePickupRequested>(_onCompletePickupRequested);
  }

  Future<void> _onLoadPickupsRequested(
    LoadPickupsRequested event,
    Emitter<PickupState> emit,
  ) async {
    emit(const PickupLoading());

    try {
      // TODO: Call use case to load pickups
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      final pickups = _getMockPickups();

      emit(PickupLoaded(pickups: pickups));
    } catch (e) {
      emit(PickupError(message: e.toString()));
    }
  }

  Future<void> _onCreatePickupRequested(
    CreatePickupRequested event,
    Emitter<PickupState> emit,
  ) async {
    emit(const CreatingPickup());

    try {
      // TODO: Call use case to create pickup
      await Future.delayed(const Duration(seconds: 2));

      final newPickup = PickupRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current-user-id',
        userName: 'Current User',
        category: event.category,
        estimatedWeight: event.estimatedWeight,
        address: event.address,
        notes: event.notes,
        status: PickupStatus.pending,
        createdAt: DateTime.now(),
      );

      emit(PickupCreated(pickup: newPickup));
      
      // Reload pickups
      add(const LoadPickupsRequested());
    } catch (e) {
      emit(PickupError(message: e.toString()));
    }
  }

  Future<void> _onAcceptPickupRequested(
    AcceptPickupRequested event,
    Emitter<PickupState> emit,
  ) async {
    if (state is! PickupLoaded) return;

    final currentState = state as PickupLoaded;
    emit(const PickupLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedPickups = currentState.pickups.map((pickup) {
        if (pickup.id == event.pickupId) {
          return pickup.copyWith(
            status: PickupStatus.accepted,
            collectorId: 'current-collector-id',
            collectorName: 'Current Collector',
            acceptedAt: DateTime.now(),
          );
        }
        return pickup;
      }).toList();

      emit(PickupLoaded(pickups: updatedPickups));
    } catch (e) {
      emit(PickupError(message: e.toString()));
    }
  }

  Future<void> _onUpdatePickupStatusRequested(
    UpdatePickupStatusRequested event,
    Emitter<PickupState> emit,
  ) async {
    if (state is! PickupLoaded) return;

    final currentState = state as PickupLoaded;
    emit(const PickupLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedPickups = currentState.pickups.map((pickup) {
        if (pickup.id == event.pickupId) {
          return pickup.copyWith(status: event.newStatus);
        }
        return pickup;
      }).toList();

      emit(PickupLoaded(pickups: updatedPickups));
    } catch (e) {
      emit(PickupError(message: e.toString()));
    }
  }

  Future<void> _onCompletePickupRequested(
    CompletePickupRequested event,
    Emitter<PickupState> emit,
  ) async {
    if (state is! PickupLoaded) return;

    final currentState = state as PickupLoaded;
    emit(const PickupLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedPickups = currentState.pickups.map((pickup) {
        if (pickup.id == event.pickupId) {
          // Calculate eco points based on weight
          final ecoPoints = (pickup.estimatedWeight * 10).toInt();
          
          return pickup.copyWith(
            status: PickupStatus.completed,
            completedAt: DateTime.now(),
            ecoPointsEarned: ecoPoints,
          );
        }
        return pickup;
      }).toList();

      emit(PickupLoaded(pickups: updatedPickups));
    } catch (e) {
      emit(PickupError(message: e.toString()));
    }
  }

  // Mock data generator
  List<PickupRequest> _getMockPickups() {
    return [
      PickupRequest(
        id: '1',
        userId: 'user1',
        userName: 'John Doe',
        category: WasteCategory.plastic,
        estimatedWeight: 5.0,
        address: '123 Main St, Dhaka, Bangladesh',
        notes: 'Please call before arriving',
        status: PickupStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      PickupRequest(
        id: '2',
        userId: 'user2',
        userName: 'Jane Smith',
        category: WasteCategory.paper,
        estimatedWeight: 10.0,
        address: '456 Park Ave, Chittagong, Bangladesh',
        status: PickupStatus.accepted,
        collectorId: 'collector1',
        collectorName: 'Mike Collector',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        acceptedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      PickupRequest(
        id: '3',
        userId: 'user3',
        userName: 'Bob Johnson',
        category: WasteCategory.metal,
        estimatedWeight: 15.0,
        address: '789 Oak Rd, Sylhet, Bangladesh',
        status: PickupStatus.onTheWay,
        collectorId: 'collector2',
        collectorName: 'Sarah Collector',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        acceptedAt: DateTime.now().subtract(const Duration(hours: 20)),
      ),
      PickupRequest(
        id: '4',
        userId: 'user4',
        userName: 'Alice Williams',
        category: WasteCategory.glass,
        estimatedWeight: 8.0,
        address: '321 Elm St, Rajshahi, Bangladesh',
        status: PickupStatus.completed,
        collectorId: 'collector1',
        collectorName: 'Mike Collector',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        acceptedAt: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
        completedAt: DateTime.now().subtract(const Duration(days: 1, hours: 20)),
        ecoPointsEarned: 80,
      ),
    ];
  }
}
