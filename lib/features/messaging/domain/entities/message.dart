import 'package:equatable/equatable.dart';
import 'package:felo_na/core/constants/enums.dart';

/// A single message within a conversation.
class Message extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String content;
  final MessageStatus status;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.status = MessageStatus.sent,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, conversationId, senderId, content, status, createdAt];
}
