import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/messaging/domain/entities/conversation.dart';
import 'package:felo_na/features/messaging/domain/repositories/messaging_repository.dart';

/// Returns an existing conversation for a listing, or creates one if none exists.
class GetOrCreateConversationUseCase
    extends UseCase<Conversation, GetOrCreateConversationParams> {
  final MessagingRepository repository;

  GetOrCreateConversationUseCase(this.repository);

  @override
  Future<Either<Failure, Conversation>> call(
          GetOrCreateConversationParams params) =>
      repository.getOrCreateConversation(
        listingId: params.listingId,
        sellerId: params.sellerId,
      );
}

class GetOrCreateConversationParams extends Equatable {
  final String listingId;
  final String sellerId;

  const GetOrCreateConversationParams({
    required this.listingId,
    required this.sellerId,
  });

  @override
  List<Object?> get props => [listingId, sellerId];
}
