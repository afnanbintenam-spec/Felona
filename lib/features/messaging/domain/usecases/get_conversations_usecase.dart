import 'package:dartz/dartz.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/messaging/domain/entities/conversation.dart';
import 'package:felo_na/features/messaging/domain/repositories/messaging_repository.dart';

/// Returns all conversations for the currently authenticated user.
class GetConversationsUseCase extends UseCase<List<Conversation>, NoParams> {
  final MessagingRepository repository;

  GetConversationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Conversation>>> call(NoParams params) =>
      repository.getConversations();
}
