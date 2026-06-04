import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/messaging/domain/entities/message.dart';
import 'package:felo_na/features/messaging/domain/repositories/messaging_repository.dart';

/// Sends a text message in an existing conversation.
class SendMessageUseCase extends UseCase<Message, SendMessageParams> {
  final MessagingRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, Message>> call(SendMessageParams params) =>
      repository.sendMessage(
        conversationId: params.conversationId,
        content: params.content,
      );
}

class SendMessageParams extends Equatable {
  final String conversationId;
  final String content;

  const SendMessageParams({
    required this.conversationId,
    required this.content,
  });

  @override
  List<Object?> get props => [conversationId, content];
}
