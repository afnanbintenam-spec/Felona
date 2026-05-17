import 'package:equatable/equatable.dart';

/// Base class for all notification events.
abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all notifications for the current user.
class LoadNotificationsRequested extends NotificationsEvent {
  const LoadNotificationsRequested();
}

/// Event to mark a notification as read.
class MarkNotificationAsReadRequested extends NotificationsEvent {
  final String notificationId;

  const MarkNotificationAsReadRequested({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

/// Event to mark all notifications as read.
class MarkAllNotificationsAsReadRequested extends NotificationsEvent {
  const MarkAllNotificationsAsReadRequested();
}

/// Event to delete a notification.
class DeleteNotificationRequested extends NotificationsEvent {
  final String notificationId;

  const DeleteNotificationRequested({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

/// Event to refresh notifications (pull to refresh).
class RefreshNotificationsRequested extends NotificationsEvent {
  const RefreshNotificationsRequested();
}

/// Event triggered when a new FCM notification is received.
class NewNotificationReceived extends NotificationsEvent {
  final Map<String, dynamic> data;

  const NewNotificationReceived({required this.data});

  @override
  List<Object?> get props => [data];
}
