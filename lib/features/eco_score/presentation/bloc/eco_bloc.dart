import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/features/eco_score/presentation/bloc/eco_event.dart';
import 'package:felo_na/features/eco_score/presentation/bloc/eco_state.dart';
import 'package:felo_na/features/eco_score/domain/repositories/eco_repository.dart';

/// BLoC for managing eco score state.
///
/// Handles eco statistics, point history, and gamification via real API calls.
class EcoBloc extends Bloc<EcoEvent, EcoState> {
  final EcoRepository _repository;

  EcoBloc({required EcoRepository repository})
      : _repository = repository,
        super(const EcoInitial()) {
    on<LoadEcoStatsRequested>(_onLoadEcoStatsRequested);
    on<LoadPointHistoryRequested>(_onLoadPointHistoryRequested);
    on<AddPointsRequested>(_onAddPointsRequested);
    on<RefreshEcoStatsRequested>(_onRefreshEcoStatsRequested);
  }

  Future<void> _onLoadEcoStatsRequested(
    LoadEcoStatsRequested event,
    Emitter<EcoState> emit,
  ) async {
    emit(const EcoLoading());

    final statsResult = await _repository.getEcoStats();
    final historyResult = await _repository.getPointHistory();

    statsResult.fold(
      (failure) => emit(EcoError(message: failure.message)),
      (stats) {
        historyResult.fold(
          (failure) => emit(EcoLoaded(stats: stats, history: const [])),
          (history) => emit(EcoLoaded(stats: stats, history: history)),
        );
      },
    );
  }

  Future<void> _onLoadPointHistoryRequested(
    LoadPointHistoryRequested event,
    Emitter<EcoState> emit,
  ) async {
    if (state is! EcoLoaded) return;

    final currentState = state as EcoLoaded;
    emit(const EcoLoading());

    final result = await _repository.getPointHistory();

    result.fold(
      (failure) => emit(EcoError(message: failure.message)),
      (history) => emit(EcoLoaded(stats: currentState.stats, history: history)),
    );
  }

  Future<void> _onAddPointsRequested(
    AddPointsRequested event,
    Emitter<EcoState> emit,
  ) async {
    if (state is! EcoLoaded) return;

    final result = await _repository.addPoints(
      points: event.points,
      reason: event.reason,
    );

    result.fold(
      (failure) => emit(EcoError(message: failure.message)),
      (updatedStats) {
        emit(PointsAdded(points: event.points));
        // Reload full stats
        add(const LoadEcoStatsRequested());
      },
    );
  }

  Future<void> _onRefreshEcoStatsRequested(
    RefreshEcoStatsRequested event,
    Emitter<EcoState> emit,
  ) async {
    add(const LoadEcoStatsRequested());
  }
}
