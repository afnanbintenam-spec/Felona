import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/features/notifications/domain/entities/notification.dart';

/// Data model for AppNotification with JSON serialization.
class NotificationModel extends AppNotification {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.title,
    required super.message,
    required super.isRead,
    required super.createdAt,
    super.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: (json['user_id'] ?? json['userId']) as String,
      type: _parseType(json['type'] as String? ?? 'general'),
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: (json['is_read'] ?? json['isRead'] ?? false) as bool,
      createdAt: DateTime.parse(
        (json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()) as String,
      ),
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': _typeToString(type),
      'title': title,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'data': data,
    };
  }

  static NotificationType _parseType(String value) {
    switch (value.toLowerCase()) {
      case 'new_offer':
        return NotificationType.newOffer;
      case 'offer_accepted':
        return NotificationType.offerAccepted;
      case 'offer_rejected':
        return NotificationType.offerRejected;
      case 'pickup_accepted':
        return NotificationType.pickupAccepted;
      case 'pickup_status_update':
      case 'pickup_status':
        return NotificationType.pickupStatusUpdate;
      case 'pickup_completed':
        return NotificationType.pickupCompleted;
      case 'new_message':
        return NotificationType.newMessage;
      case 'eco_milestone':
        return NotificationType.ecoMilestone;
      default:
        return NotificationType.general;
    }
  }

  static String _typeToString(NotificationType type) {
    switch (type) {
      case NotificationType.newOffer:
        return 'new_offer';
      case NotificationType.offerAccepted:
        return 'offer_accepted';
      case NotificationType.offerRejected:
        return 'offer_rejected';
      case NotificationType.pickupAccepted:
        return 'pickup_accepted';
      case NotificationType.pickupStatusUpdate:
        return 'pickup_status_update';
      case NotificationType.pickupCompleted:
        return 'pickup_completed';
      case NotificationType.newMessage:
        return 'new_message';
      case NotificationType.ecoMilestone:
        return 'eco_milestone';
      case NotificationType.general:
        return 'general';
    }
  }
}
