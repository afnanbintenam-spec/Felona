import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/features/messaging/domain/entities/message.dart';

/// Data model for [Message] with JSON serialization.
class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.senderName,
    required super.content,
    super.status,
    required super.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>? ?? {};
    return MessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? '',
      senderId: (json['sender_id'] ?? sender['id'] ?? '')?.toString() ?? '',
      senderName: (json['sender_name'] ?? sender['full_name'] ?? 'User')?.toString() ?? 'User',
      content: json['content']?.toString() ?? '',
      status: _parseStatus(json['status']?.toString()),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  static MessageStatus _parseStatus(String? value) {
    switch (value) {
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      default:
        return MessageStatus.sent;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversation_id': conversationId,
        'sender_id': senderId,
        'content': content,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
      };
}
