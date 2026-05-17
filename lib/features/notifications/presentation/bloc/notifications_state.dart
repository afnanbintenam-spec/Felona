import 'package:equatable/equatable.dart';
import 'package:felo_na/features/notifications/domain/entities/notification.dart';

/// Base class for all notification states.
abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any notifications are loaded.
class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

/// State when notifications are being loaded.
class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

/// State when notifications are successfully loaded.
class NotificationsLoaded extends NotificationsState {
  final List<AppNotification> notifications;
  final int unreadCount;

  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

/// State when a notification is marked as read.
class NotificationMarkedAsRead extends NotificationsState {
  final String notificationId;

  const NotificationMarkedAsRead({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

/// State when all notifications are marked as read.
class AllNotificationsMarkedAsRead extends NotificationsState {
  const AllNotificationsMarkedAsRead();
}

/// State when a notification is deleted.
class NotificationDeleted extends NotificationsState {
  final String notificationId;

  const NotificationDeleted({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

/// State when there's an error loading or managing notifications.
class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError({required this.message});

  @override
  List<Object?> get props => [message];
}
