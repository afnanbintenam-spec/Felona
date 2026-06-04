import 'package:equatable/equatable.dart';
import 'package:felo_na/features/messaging/domain/entities/conversation.dart';
import 'package:felo_na/features/messaging/domain/entities/message.dart';

abstract class MessagingState extends Equatable {
  const MessagingState();
  @override
  List<Object?> get props => [];
}

class MessagingInitial extends MessagingState {
  const MessagingInitial();
}

class MessagingLoading extends MessagingState {
  const MessagingLoading();
}

class ConversationsLoaded extends MessagingState {
  final List<Conversation> conversations;
  const ConversationsLoaded({required this.conversations});
  @override
  List<Object?> get props => [conversations];
}

class ConversationOpened extends MessagingState {
  final Conversation conversation;
  final List<Message> messages;
  final bool isSending;
  const ConversationOpened({
    required this.conversation,
    required this.messages,
    this.isSending = false,
  });
  @override
  List<Object?> get props => [conversation, messages, isSending];

  ConversationOpened copyWith({
    Conversation? conversation,
    List<Message>? messages,
    bool? isSending,
  }) {
    return ConversationOpened(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }
}

class MessagingError extends MessagingState {
  final String message;
  const MessagingError({required this.message});
  @override
  List<Object?> get props => [message];
}

class OpeningConversation extends MessagingState {
  const OpeningConversation();
}
