import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:felo_na/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:felo_na/features/notifications/domain/entities/notification.dart';
import 'package:felo_na/core/constants/enums.dart';

/// BLoC for managing notifications state.
///
/// Handles notification loading, marking as read, and FCM integration.
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc() : super(const NotificationsInitial()) {
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

    try {
      // TODO: Call use case to load notifications
      await Future.delayed(const Duration(seconds: 1));

      final notifications = _getMockNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;

      emit(NotificationsLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationsError(message: e.toString()));
    }
  }

  Future<void> _onMarkNotificationAsReadRequested(
    MarkNotificationAsReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is! NotificationsLoaded) return;

    final currentState = state as NotificationsLoaded;

    try {
      // TODO: Call use case to mark notification as read
      await Future.delayed(const Duration(milliseconds: 300));

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
    } catch (e) {
      emit(NotificationsError(message: e.toString()));
    }
  }

  Future<void> _onMarkAllNotificationsAsReadRequested(
    MarkAllNotificationsAsReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is! NotificationsLoaded) return;

    final currentState = state as NotificationsLoaded;

    try {
      // TODO: Call use case to mark all notifications as read
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedNotifications = currentState.notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();

      emit(const AllNotificationsMarkedAsRead());
      emit(NotificationsLoaded(
        notifications: updatedNotifications,
        unreadCount: 0,
      ));
    } catch (e) {
      emit(NotificationsError(message: e.toString()));
    }
  }

  Future<void> _onDeleteNotificationRequested(
    DeleteNotificationRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is! NotificationsLoaded) return;

    final currentState = state as NotificationsLoaded;

    try {
      // TODO: Call use case to delete notification
      await Future.delayed(const Duration(milliseconds: 300));

      final updatedNotifications = currentState.notifications
          .where((n) => n.id != event.notificationId)
          .toList();

      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

      emit(NotificationDeleted(notificationId: event.notificationId));
      emit(NotificationsLoaded(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationsError(message: e.toString()));
    }
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
    if (state is! NotificationsLoaded) return;

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

  // Mock data generator
  List<AppNotification> _getMockNotifications() {
    return [
      AppNotification(
        id: '1',
        userId: 'current-user-id',
        type: NotificationType.newOffer,
        title: 'New Offer Received',
        message: 'John Doe offered \$25 for your Old Laptop',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        data: {'listingId': 'listing-1', 'offerId': 'offer-1'},
      ),
      AppNotification(
        id: '2',
        userId: 'current-user-id',
        type: NotificationType.pickupAccepted,
        title: 'Pickup Accepted',
        message: 'Collector Mike accepted your pickup request',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        data: {'pickupId': 'pickup-1'},
      ),
      AppNotification(
        id: '3',
        userId: 'current-user-id',
        type: NotificationType.pickupStatusUpdate,
        title: 'Collector On The Way',
        message: 'Mike is on the way to your location',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        data: {'pickupId': 'pickup-1'},
      ),
      AppNotification(
        id: '4',
        userId: 'current-user-id',
        type: NotificationType.offerAccepted,
        title: 'Offer Accepted',
        message: 'Sarah accepted your offer of \$30 for Vintage Chair',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        data: {'listingId': 'listing-2', 'offerId': 'offer-2'},
      ),
      AppNotification(
        id: '5',
        userId: 'current-user-id',
        type: NotificationType.pickupCompleted,
        title: 'Pickup Completed',
        message: 'Pickup completed! You earned 50 eco points 🌱',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        data: {'pickupId': 'pickup-2', 'points': 50},
      ),
      AppNotification(
        id: '6',
        userId: 'current-user-id',
        type: NotificationType.newMessage,
        title: 'New Message',
        message: 'Emma sent you a message about Plastic Bottles',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        data: {'conversationId': 'conv-1'},
      ),
    ];
  }
}
