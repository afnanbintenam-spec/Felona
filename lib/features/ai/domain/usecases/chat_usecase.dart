import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/ai/domain/repositories/ai_repository.dart';

/// Sends a message to the Gemini recycling assistant and returns the reply.
class ChatUseCase extends UseCase<String, ChatParams> {
  final AiRepository repository;

  ChatUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(ChatParams params) =>
      repository.chat(params.message);
}

class ChatParams extends Equatable {
  final String message;

  const ChatParams({required this.message});

  @override
  List<Object?> get props => [message];
}
