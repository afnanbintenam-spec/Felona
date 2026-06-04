import 'package:dartz/dartz.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/messaging/domain/entities/conversation.dart';
import 'package:felo_na/features/messaging/domain/entities/message.dart';

/// Repository interface for messaging operations.
abstract class MessagingRepository {
  /// Returns all conversations for the current user.
  Future<Either<Failure, List<Conversation>>> getConversations();

  /// Returns messages in a specific conversation.
  Future<Either<Failure, List<Message>>> getMessages(String conversationId);

  /// Creates or retrieves an existing conversation for a listing.
  Future<Either<Failure, Conversation>> getOrCreateConversation({
    required String listingId,
    required String sellerId,
  });

  /// Sends a message in a conversation.
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String content,
  });

  /// Marks all messages in a conversation as read.
  Future<Either<Failure, void>> markAsRead(String conversationId);
}
