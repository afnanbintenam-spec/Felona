import 'package:dartz/dartz.dart';
import 'package:felo_na/core/errors/exceptions.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/messaging/data/datasources/messaging_remote_data_source.dart';
import 'package:felo_na/features/messaging/domain/entities/conversation.dart';
import 'package:felo_na/features/messaging/domain/entities/message.dart';
import 'package:felo_na/features/messaging/domain/repositories/messaging_repository.dart';

class MessagingRepositoryImpl implements MessagingRepository {
  final MessagingRemoteDataSource _remoteDataSource;

  MessagingRepositoryImpl({required MessagingRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<Conversation>>> getConversations() async {
    try {
      return Right(await _remoteDataSource.getConversations());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to load conversations: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(String conversationId) async {
    try {
      return Right(await _remoteDataSource.getMessages(conversationId));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to load messages: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Conversation>> getOrCreateConversation({
    required String listingId,
    required String sellerId,
  }) async {
    try {
      return Right(await _remoteDataSource.getOrCreateConversation(
        listingId: listingId,
        sellerId: sellerId,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to open conversation: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      return Right(await _remoteDataSource.sendMessage(
        conversationId: conversationId,
        content: content,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to send message: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String conversationId) async {
    try {
      await _remoteDataSource.markAsRead(conversationId);
      return const Right(null);
    } catch (_) {
      return const Right(null); // Silently fail — non-critical
    }
  }
}
