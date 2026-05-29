import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_event.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_state.dart';
import 'package:felo_na/features/pickup/domain/repositories/pickup_repository.dart';

/// BLoC for managing pickup state.
///
/// Handles pickup request operations, scheduling, status updates,
/// tracking, QR verification, and rating.
class PickupBloc extends Bloc<PickupEvent, PickupState> {
  final PickupRepository _repository;

  PickupBloc({required PickupRepository repository})
      : _repository = repository,
        super(const PickupInitial()) {
    on<LoadPickupsRequested>(_onLoadPickupsRequested);
    on<CreatePickupRequested>(_onCreatePickupRequested);
    on<LoadPickupDetailRequested>(_onLoadPickupDetailRequested);
    on<AcceptPickupRequested>(_onAcceptPickupRequested);
    on<UpdatePickupStatusRequested>(_onUpdatePickupStatusRequested);
    on<CompletePickupRequested>(_onCompletePickupRequested);
    on<LoadPickupHistoryRequested>(_onLoadPickupHistoryRequested);
    on<RatePickupRequested>(_onRatePickupRequested);
    on<VerifyPickupQrRequested>(_onVerifyPickupQrRequested);
    on<RefreshTrackingRequested>(_onRefreshTrackingRequested);
    on<CancelRecurringScheduleRequested>(_onCancelRecurringScheduleRequested);
  }

  Future<void> _onLoadPickupsRequested(
    LoadPickupsRequested event,
    Emitter<PickupState> emit,
  ) async {
    emit(const PickupLoading());

    final result = await _repository.getPickups();

    result.fold(
      (failure) => emit(PickupError(message: failure.message)),
      (pickups) => emit(PickupLoaded(pickups: pickups)),
    );
  }

  Future<void> _onCreatePickupRequested(
    CreatePickupRequested event,
    Emitter<PickupState> emit,
  ) async {
    emit(const CreatingPickup());

    final result = await _repository.createPickup(
      category: event.category,
      estimatedWeight: event.estimatedWeight,
      address: event.address,
      latitude: event.latitude,
      longitude: event.longitude,
      notes: event.notes,
      scheduledDate: event.scheduledDate,
      timeSlot: event.timeSlot,
      isRecurring: event.isRecurring,
      recurrenceFrequency: event.recurrenceFrequency,
      recurrenceDayOfWeek: event.recurrenceDayOfWeek,
    );

    result.fold(
      (failure) => emit(PickupError(message: failure.message)),
      (pickup) {
        emit(PickupCreated(pickup: pickup));
      },
    );
  }

  Future<void> _onLoadPickupDetailRequested(
    LoadPickupDetailRequested event,
    Emitter<PickupState> emit,
  ) async {
    emit(const PickupLoading());

    final result = await _repository.getPickupById(event.pickupId);

    result.fold(
      (failure) => emit(PickupError(message: failure.message)),
      (pickup) => emit(PickupDetailLoaded(pickup: pickup)),
    );
  }

  Future<void> _onAcceptPickupRequested(
    AcceptPickupRequested event,
    Emitter<PickupState> emit,
  ) async {
    emit(const PickupLoading());

    final result = await _repository.acceptPickup(event.pickupId);

    result.fold(
      (failure) => emit(PickupError(message: failure.message)),
      (pickup) {
        emit(PickupStatusUpdated(pickup: pickup));
      },
    );
  }

  Future<void> _onUpdatePickupStatusRequested(
    UpdatePickupStatusRequested event,
    Emitter<PickupState> emit,
  ) async {
    emit(const PickupLoading());

    final result =
        await _repository.updatePickupStatus(event.pickupId, event.newStatus);

    result.fold(
      (failure) => emit(PickupError(message: failure.message)),
      (pickup) {
        emit(PickupStatusUpdated(pickup: pickup));
      },
    );
  }

  Future<void> _onCompletePickupRequested(
    CompletePickupRequested event,
    Emitter<PickupState> emit,
  ) async {
    emit(const PickupLoading());

    final result = await _repository.completePickup(event.pickupId);

    result.fold(
      (failure) => emit(PickupError(message: failure.message)),
      (pickup) {
        emit(PickupStatusUpdated(pickup: pickup));
      },
    );
  }

  Future<void> _onLoadPickupHistoryRequested(
    LoadPickupHistoryRequested event,
    Emitter<PickupState> emit,
  ) async {
    emit(const PickupLoading());

    final result = await _repository.getMyPickupHistory(
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(PickupError(message: failure.message)),
      (pickups) => emit(PickupHistoryLoaded(
        pickups: pickups,
        currentPage: event.page,
        hasMore: pickups.length >= event.limit,
      )),
    );
  }

  Future<void> _onRatePickupRequested(
    RatePickupRequested event,
    Emitter<PickupState> emit,
  ) async {
    emit(const PickupLoading());

    final result = await _repository.ratePickup(
      pickupId: event.pickupId,
      rating: event.rating,
      feedback: event.feedback,
    );

    result.fold(
      (failure) => emit(PickupError(message: failure.message)),
      (pickup) => emit(PickupRated(pickup: pickup)),
    );
  }

  Future<void> _onVerifyPickupQrRequested(
    VerifyPickupQrRequested event,
    Emitter<PickupState> emit,
  ) async {
    emit(const PickupLoading());

    final result = await _repository.verifyPickupQr(
      pickupId: event.pickupId,
      qrToken: event.qrToken,
    );

    result.fold(
      (failure) => emit(PickupError(message: failure.message)),
      (pickup) => emit(PickupQrVerified(pickup: pickup)),
    );
  }

  Future<void> _onRefreshTrackingRequested(
    RefreshTrackingRequested event,
    Emitter<PickupState> emit,
  ) async {
    final result = await _repository.getPickupTracking(event.pickupId);

    result.fold(
      (failure) => emit(PickupError(message: failure.message)),
      (pickup) => emit(PickupTrackingUpdated(pickup: pickup)),
    );
  }

  Future<void> _onCancelRecurringScheduleRequested(
    CancelRecurringScheduleRequested event,
    Emitter<PickupState> emit,
  ) async {
    emit(const PickupLoading());

    final result =
        await _repository.cancelRecurringSchedule(event.scheduleId);

    result.fold(
      (failure) => emit(PickupError(message: failure.message)),
      (_) => emit(const RecurringScheduleCancelled()),
    );
  }
}
