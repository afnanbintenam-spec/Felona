import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/messaging/domain/entities/message.dart';
import 'package:felo_na/features/messaging/domain/repositories/messaging_repository.dart';

/// Returns all messages in a given conversation thread.
class GetMessagesUseCase extends UseCase<List<Message>, GetMessagesParams> {
  final MessagingRepository repository;

  GetMessagesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Message>>> call(GetMessagesParams params) =>
      repository.getMessages(params.conversationId);
}

class GetMessagesParams extends Equatable {
  final String conversationId;

  const GetMessagesParams({required this.conversationId});

  @override
  List<Object?> get props => [conversationId];
}
