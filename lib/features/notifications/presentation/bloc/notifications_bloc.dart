import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:felo_na/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:felo_na/features/notifications/domain/entities/notification.dart';
import 'package:felo_na/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:felo_na/core/constants/enums.dart';

/// BLoC for managing notifications state.
///
/// Handles notification loading, marking as read, and FCM integration via real API calls.
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository _repository;

  NotificationsBloc({required NotificationsRepository repository})
      : _repository = repository,
        super(const NotificationsInitial()) {
    on<LoadNotificationsRequested>(_onLoadNotificationsRequested);
    on<MarkNotificationAsReadRequested>(_onMarkNotificationAsReadRequested);
    on<MarkAllNotificationsAsReadRequested>(_onMarkAllNotificationsAsReadRequested);
    on<DeleteNotificationRequested>(_onDeleteNotificationRequested);
    on<RefreshNotificationsRequested>(_onRefreshNotificationsRequested);
    on<NewNotificationReceived>(_onNewNotificationReceived);
  }

  Future<void> _onLoadNotificationsRequested(
    LoadNotificationsRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoading());

    final result = await _repository.getNotifications();

    result.fold(
      (failure) => emit(NotificationsError(message: failure.message)),
      (notifications) {
        final unreadCount = notifications.where((n) => !n.isRead).length;
        emit(NotificationsLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ));
      },
    );
  }

  Future<void> _onMarkNotificationAsReadRequested(
    MarkNotificationAsReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is! NotificationsLoaded) return;

    final currentState = state as NotificationsLoaded;

    // Optimistic update
    final updatedNotifications = currentState.notifications.map((n) {
      if (n.id == event.notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

    emit(NotificationMarkedAsRead(notificationId: event.notificationId));
    emit(NotificationsLoaded(
      notifications: updatedNotifications,
      unreadCount: unreadCount,
    ));

    // Call API in background
    await _repository.markAsRead(event.notificationId);
  }

  Future<void> _onMarkAllNotificationsAsReadRequested(
    MarkAllNotificationsAsReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is! NotificationsLoaded) return;

    final currentState = state as NotificationsLoaded;

    // Optimistic update
    final updatedNotifications = currentState.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();

    emit(const AllNotificationsMarkedAsRead());
    emit(NotificationsLoaded(
      notifications: updatedNotifications,
      unreadCount: 0,
    ));

    // Call API in background
    await _repository.markAllAsRead();
  }

  Future<void> _onDeleteNotificationRequested(
    DeleteNotificationRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is! NotificationsLoaded) return;

    final currentState = state as NotificationsLoaded;

    // Optimistic update
    final updatedNotifications = currentState.notifications
        .where((n) => n.id != event.notificationId)
        .toList();

    final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

    emit(NotificationDeleted(notificationId: event.notificationId));
    emit(NotificationsLoaded(
      notifications: updatedNotifications,
      unreadCount: unreadCount,
    ));

    // Call API in background
    await _repository.deleteNotification(event.notificationId);
  }

  Future<void> _onRefreshNotificationsRequested(
    RefreshNotificationsRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    add(const LoadNotificationsRequested());
  }

  Future<void> _onNewNotificationReceived(
    NewNotificationReceived event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is! NotificationsLoaded) {
      // If not loaded yet, just load from API
      add(const LoadNotificationsRequested());
      return;
    }

    final currentState = state as NotificationsLoaded;

    // Create new notification from FCM data
    final newNotification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current-user-id',
      type: _parseNotificationType(event.data['type'] as String?),
      title: event.data['title'] as String? ?? 'New Notification',
      message: event.data['message'] as String? ?? '',
      isRead: false,
      createdAt: DateTime.now(),
      data: event.data,
    );

    final updatedNotifications = [newNotification, ...currentState.notifications];
    final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

    emit(NotificationsLoaded(
      notifications: updatedNotifications,
      unreadCount: unreadCount,
    ));
  }

  NotificationType _parseNotificationType(String? type) {
    switch (type) {
      case 'new_offer':
        return NotificationType.newOffer;
      case 'offer_accepted':
        return NotificationType.offerAccepted;
      case 'offer_rejected':
        return NotificationType.offerRejected;
      case 'pickup_accepted':
        return NotificationType.pickupAccepted;
      case 'pickup_status':
        return NotificationType.pickupStatusUpdate;
      case 'pickup_completed':
        return NotificationType.pickupCompleted;
      case 'new_message':
        return NotificationType.newMessage;
      default:
        return NotificationType.general;
    }
  }
}
