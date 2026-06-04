import 'package:dartz/dartz.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/notifications/domain/repositories/notifications_repository.dart';

/// Marks every notification for the current user as read in a single API call.
class MarkAllNotificationsReadUseCase extends UseCase<void, NoParams> {
  final NotificationsRepository repository;

  MarkAllNotificationsReadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) =>
      repository.markAllAsRead();
}
