import 'package:equatable/equatable.dart';
import 'package:felo_na/features/eco_score/domain/entities/eco_stats.dart';

/// Base class for all eco score states.
abstract class EcoState extends Equatable {
  const EcoState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class EcoInitial extends EcoState {
  const EcoInitial();
}

/// Loading state.
class EcoLoading extends EcoState {
  const EcoLoading();
}

/// Loaded state with eco statistics.
class EcoLoaded extends EcoState {
  final EcoStats stats;
  final List<PointHistory> history;

  const EcoLoaded({
    required this.stats,
    required this.history,
  });

  @override
  List<Object?> get props => [stats, history];
}

/// Error state.
class EcoError extends EcoState {
  final String message;

  const EcoError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Points added successfully.
class PointsAdded extends EcoState {
  final int points;

  const PointsAdded({required this.points});

  @override
  List<Object?> get props => [points];
}
