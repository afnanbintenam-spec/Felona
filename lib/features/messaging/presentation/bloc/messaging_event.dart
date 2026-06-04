import 'package:equatable/equatable.dart';

abstract class MessagingEvent extends Equatable {
  const MessagingEvent();
  @override
  List<Object?> get props => [];
}

class LoadConversationsRequested extends MessagingEvent {
  const LoadConversationsRequested();
}

class LoadMessagesRequested extends MessagingEvent {
  final String conversationId;
  const LoadMessagesRequested({required this.conversationId});
  @override
  List<Object?> get props => [conversationId];
}

class OpenConversationRequested extends MessagingEvent {
  final String listingId;
  final String sellerId;
  final String listingTitle;
  const OpenConversationRequested({
    required this.listingId,
    required this.sellerId,
    required this.listingTitle,
  });
  @override
  List<Object?> get props => [listingId, sellerId];
}

class SendMessageRequested extends MessagingEvent {
  final String conversationId;
  final String content;
  const SendMessageRequested({
    required this.conversationId,
    required this.content,
  });
  @override
  List<Object?> get props => [conversationId, content];
}

class MarkConversationAsRead extends MessagingEvent {
  final String conversationId;
  const MarkConversationAsRead({required this.conversationId});
  @override
  List<Object?> get props => [conversationId];
}

/// Triggered by the poll timer to refresh messages.
class PollMessagesRequested extends MessagingEvent {
  final String conversationId;
  const PollMessagesRequested({required this.conversationId});
  @override
  List<Object?> get props => [conversationId];
}
