import 'package:equatable/equatable.dart';

/// Base class for all eco score events.
abstract class EcoEvent extends Equatable {
  const EcoEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load eco statistics.
class LoadEcoStatsRequested extends EcoEvent {
  const LoadEcoStatsRequested();
}

/// Event to load point history.
class LoadPointHistoryRequested extends EcoEvent {
  const LoadPointHistoryRequested();
}

/// Event to add points.
class AddPointsRequested extends EcoEvent {
  final int points;
  final String reason;

  const AddPointsRequested({
    required this.points,
    required this.reason,
  });

  @override
  List<Object?> get props => [points, reason];
}

/// Event to refresh stats.
class RefreshEcoStatsRequested extends EcoEvent {
  const RefreshEcoStatsRequested();
}
