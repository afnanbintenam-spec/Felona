import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/core/constants/app_colors.dart';
import 'package:felo_na/core/constants/app_text_styles.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/widgets/loading/loading_indicator.dart';
import 'package:felo_na/core/widgets/empty_states/empty_state.dart';
import 'package:felo_na/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:felo_na/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:felo_na/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:felo_na/features/notifications/domain/entities/notification.dart';

/// Notifications screen showing all user notifications.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<NotificationsBloc>().add(const LoadNotificationsRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF0A0A0A),
        foregroundColor: AppColors.gray900,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary500,
          unselectedLabelColor: AppColors.gray500,
          indicatorColor: AppColors.primary500,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Offers'),
            Tab(text: 'Pickups'),
            Tab(text: 'Messages'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context
                  .read<NotificationsBloc>()
                  .add(const MarkAllNotificationsAsReadRequested());
            },
            child: Text(
              'Mark All Read',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary500,
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<NotificationsBloc, NotificationsState>(
        listener: (context, state) {
          if (state is NotificationMarkedAsRead) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notification marked as read'),
                duration: Duration(seconds: 1),
              ),
            );
          } else if (state is AllNotificationsMarkedAsRead) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('All notifications marked as read'),
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state is NotificationDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notification deleted'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const LoadingIndicator(message: 'Loading notifications...');
          } else if (state is NotificationsError) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Error',
              description: state.message,
              actionLabel: 'Retry',
              onAction: () {
                context
                    .read<NotificationsBloc>()
                    .add(const LoadNotificationsRequested());
              },
            );
          } else if (state is NotificationsLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationsList(state.notifications),
                _buildNotificationsList(
                  state.notifications
                      .where((n) =>
                          n.type == NotificationType.newOffer ||
                          n.type == NotificationType.offerAccepted ||
                          n.type == NotificationType.offerRejected)
                      .toList(),
                ),
                _buildNotificationsList(
                  state.notifications
                      .where((n) =>
                          n.type == NotificationType.pickupAccepted ||
                          n.type == NotificationType.pickupStatusUpdate ||
                          n.type == NotificationType.pickupCompleted)
                      .toList(),
                ),
                _buildNotificationsList(
                  state.notifications
                      .where((n) => n.type == NotificationType.newMessage)
                      .toList(),
                ),
              ],
            );
          }

          return const EmptyState(
            icon: Icons.notifications_none,
            title: 'No Notifications',
            description: 'You\'re all caught up!',
          );
        },
      ),
    );
  }

  Widget _buildNotificationsList(List<AppNotification> notifications) {
    if (notifications.isEmpty) {
      return const EmptyState(
        icon: Icons.notifications_none,
        title: 'No Notifications',
        description: 'You\'re all caught up!',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<NotificationsBloc>()
            .add(const RefreshNotificationsRequested());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: AppColors.white,
        ),
      ),
      onDismissed: (direction) {
        context
            .read<NotificationsBloc>()
            .add(DeleteNotificationRequested(notificationId: notification.id));
      },
      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) {
            context.read<NotificationsBloc>().add(
                  MarkNotificationAsReadRequested(
                    notificationId: notification.id,
                  ),
                );
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead ? AppColors.white : AppColors.primary50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.gray200
                  : AppColors.primary200,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray900,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary500,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.gray700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(notification.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: AppColors.gray400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newOffer:
        return Icons.local_offer;
      case NotificationType.offerAccepted:
        return Icons.check_circle;
      case NotificationType.offerRejected:
        return Icons.cancel;
      case NotificationType.pickupAccepted:
        return Icons.local_shipping;
      case NotificationType.pickupStatusUpdate:
        return Icons.location_on;
      case NotificationType.pickupCompleted:
        return Icons.check_circle;
      case NotificationType.newMessage:
        return Icons.message;
      case NotificationType.ecoMilestone:
        return Icons.eco;
      case NotificationType.general:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.newOffer:
        return AppColors.accent500;
      case NotificationType.offerAccepted:
        return AppColors.success;
      case NotificationType.offerRejected:
        return AppColors.error;
      case NotificationType.pickupAccepted:
        return AppColors.secondary500;
      case NotificationType.pickupStatusUpdate:
        return AppColors.info;
      case NotificationType.pickupCompleted:
        return AppColors.success;
      case NotificationType.newMessage:
        return AppColors.primary500;
      case NotificationType.ecoMilestone:
        return AppColors.primary500;
      case NotificationType.general:
        return AppColors.gray500;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
