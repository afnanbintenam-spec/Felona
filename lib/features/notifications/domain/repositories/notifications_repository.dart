import 'package:dartz/dartz.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/notifications/domain/entities/notification.dart';

/// Repository interface for notification operations.
abstract class NotificationsRepository {
  Future<Either<Failure, List<AppNotification>>> getNotifications();
  Future<Either<Failure, void>> markAsRead(String notificationId);
  Future<Either<Failure, void>> markAllAsRead();
  Future<Either<Failure, void>> deleteNotification(String notificationId);
  Future<Either<Failure, void>> registerFcmToken(String token);
}
