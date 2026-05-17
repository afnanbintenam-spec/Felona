import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:felo_na/core/errors/failures.dart';

/// Base class for all use cases in the application.
///
/// Use cases represent single units of business logic in the domain layer.
/// Each use case has a single responsibility and depends only on repository
/// interfaces, not concrete implementations.
///
/// Type parameters:
/// - [T]: The success return type
/// - [Params]: The parameters class (use [NoParams] if none needed)
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Used when a use case does not require any parameters.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
