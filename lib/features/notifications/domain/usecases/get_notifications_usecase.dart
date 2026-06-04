import 'package:dartz/dartz.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/notifications/domain/entities/notification.dart';
import 'package:felo_na/features/notifications/domain/repositories/notifications_repository.dart';

/// Returns all notifications for the current user.
class GetNotificationsUseCase
    extends UseCase<List<AppNotification>, NoParams> {
  final NotificationsRepository repository;

  GetNotificationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AppNotification>>> call(NoParams params) =>
      repository.getNotifications();
}
