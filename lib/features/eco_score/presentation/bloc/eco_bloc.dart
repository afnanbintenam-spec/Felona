import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/features/eco_score/presentation/bloc/eco_event.dart';
import 'package:felo_na/features/eco_score/presentation/bloc/eco_state.dart';
import 'package:felo_na/features/eco_score/domain/entities/eco_stats.dart';
import 'package:felo_na/core/constants/enums.dart';

/// BLoC for managing eco score state.
///
/// Handles eco statistics, point history, and gamification.
class EcoBloc extends Bloc<EcoEvent, EcoState> {
  EcoBloc() : super(const EcoInitial()) {
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

    try {
      // TODO: Call use case to load eco stats
      await Future.delayed(const Duration(seconds: 1));

      final stats = _getMockEcoStats();
      final history = _getMockPointHistory();

      emit(EcoLoaded(stats: stats, history: history));
    } catch (e) {
      emit(EcoError(message: e.toString()));
    }
  }

  Future<void> _onLoadPointHistoryRequested(
    LoadPointHistoryRequested event,
    Emitter<EcoState> emit,
  ) async {
    if (state is! EcoLoaded) return;

    final currentState = state as EcoLoaded;
    emit(const EcoLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final history = _getMockPointHistory();

      emit(EcoLoaded(stats: currentState.stats, history: history));
    } catch (e) {
      emit(EcoError(message: e.toString()));
    }
  }

  Future<void> _onAddPointsRequested(
    AddPointsRequested event,
    Emitter<EcoState> emit,
  ) async {
    if (state is! EcoLoaded) return;

    final currentState = state as EcoLoaded;

    try {
      // Add points to current stats
      final newTotalPoints = currentState.stats.totalPoints + event.points;
      final newBadge = _calculateBadge(newTotalPoints);

      final updatedStats = currentState.stats.copyWith(
        totalPoints: newTotalPoints,
        currentBadge: newBadge,
        lastActivityDate: DateTime.now(),
      );

      // Add to history
      final newHistoryEntry = PointHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        points: event.points,
        reason: event.reason,
        date: DateTime.now(),
      );

      final updatedHistory = [newHistoryEntry, ...currentState.history];

      emit(PointsAdded(points: event.points));
      emit(EcoLoaded(stats: updatedStats, history: updatedHistory));
    } catch (e) {
      emit(EcoError(message: e.toString()));
    }
  }

  Future<void> _onRefreshEcoStatsRequested(
    RefreshEcoStatsRequested event,
    Emitter<EcoState> emit,
  ) async {
    add(const LoadEcoStatsRequested());
  }

  EcoBadgeType _calculateBadge(int points) {
    if (points >= EcoBadgeType.champion.requiredPoints) {
      return EcoBadgeType.champion;
    } else if (points >= EcoBadgeType.platinum.requiredPoints) {
      return EcoBadgeType.platinum;
    } else if (points >= EcoBadgeType.gold.requiredPoints) {
      return EcoBadgeType.gold;
    } else if (points >= EcoBadgeType.silver.requiredPoints) {
      return EcoBadgeType.silver;
    } else if (points >= EcoBadgeType.bronze.requiredPoints) {
      return EcoBadgeType.bronze;
    } else {
      return EcoBadgeType.beginner;
    }
  }

  // Mock data generators
  EcoStats _getMockEcoStats() {
    return EcoStats(
      userId: 'current-user-id',
      totalPoints: 350,
      totalWeightRecycled: 45.5,
      itemsSold: 8,
      pickupsCompleted: 12,
      co2Reduced: 68.25, // Approximate: weight * 1.5
      currentBadge: EcoBadgeType.bronze,
      currentStreak: 5,
      longestStreak: 12,
      lastActivityDate: DateTime.now(),
      milestones: [
        const EcoMilestone(
          id: '1',
          title: 'First Steps',
          description: 'Complete your first pickup',
          requiredPoints: 10,
          isAchieved: true,
          achievedAt: null,
        ),
        const EcoMilestone(
          id: '2',
          title: 'Eco Warrior',
          description: 'Reach 100 eco points',
          requiredPoints: 100,
          isAchieved: true,
          achievedAt: null,
        ),
        const EcoMilestone(
          id: '3',
          title: 'Green Champion',
          description: 'Reach 500 eco points',
          requiredPoints: 500,
          isAchieved: false,
        ),
        const EcoMilestone(
          id: '4',
          title: 'Planet Saver',
          description: 'Reach 1000 eco points',
          requiredPoints: 1000,
          isAchieved: false,
        ),
      ],
    );
  }

  List<PointHistory> _getMockPointHistory() {
    return [
      PointHistory(
        id: '1',
        points: 50,
        reason: 'Pickup completed - 5kg plastic',
        date: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      PointHistory(
        id: '2',
        points: 30,
        reason: 'Item sold - Old laptop',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      PointHistory(
        id: '3',
        points: 80,
        reason: 'Pickup completed - 8kg paper',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      PointHistory(
        id: '4',
        points: 25,
        reason: 'Item sold - Books collection',
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
      PointHistory(
        id: '5',
        points: 100,
        reason: 'Pickup completed - 10kg metal',
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
      PointHistory(
        id: '6',
        points: 40,
        reason: 'Item sold - Furniture',
        date: DateTime.now().subtract(const Duration(days: 7)),
      ),
      PointHistory(
        id: '7',
        points: 25,
        reason: 'Weekly streak bonus',
        date: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }
}
