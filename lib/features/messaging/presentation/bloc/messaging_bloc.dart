import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felo_na/features/messaging/domain/repositories/messaging_repository.dart';
import 'messaging_event.dart';
import 'messaging_state.dart';

/// BLoC for messaging — REST-based with periodic polling.
///
/// Polls for new messages every 8 seconds when a conversation is open.
/// Can be upgraded to WebSocket by swapping the data source later.
class MessagingBloc extends Bloc<MessagingEvent, MessagingState> {
  final MessagingRepository _repository;
  Timer? _pollTimer;

  MessagingBloc({required MessagingRepository repository})
      : _repository = repository,
        super(const MessagingInitial()) {
    on<LoadConversationsRequested>(_onLoadConversations);
    on<OpenConversationRequested>(_onOpenConversation);
    on<LoadMessagesRequested>(_onLoadMessages);
    on<SendMessageRequested>(_onSendMessage);
    on<MarkConversationAsRead>(_onMarkAsRead);
    on<PollMessagesRequested>(_onPollMessages);
  }

  void _startPolling(String conversationId) {
    _stopPolling();
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      add(PollMessagesRequested(conversationId: conversationId));
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _onLoadConversations(
    LoadConversationsRequested event,
    Emitter<MessagingState> emit,
  ) async {
    emit(const MessagingLoading());
    final result = await _repository.getConversations();
    result.fold(
      (failure) => emit(MessagingError(message: failure.message)),
      (conversations) => emit(ConversationsLoaded(conversations: conversations)),
    );
  }

  Future<void> _onOpenConversation(
    OpenConversationRequested event,
    Emitter<MessagingState> emit,
  ) async {
    emit(const OpeningConversation());
    final result = await _repository.getOrCreateConversation(
      listingId: event.listingId,
      sellerId: event.sellerId,
    );

    // Avoid async closure inside fold — use early-return pattern instead.
    if (result.isLeft()) {
      result.fold(
        (failure) => emit(MessagingError(message: failure.message)),
        (_) {},
      );
      return;
    }

    final conversation = result.getOrElse(() => throw StateError('unreachable'));
    final msgResult = await _repository.getMessages(conversation.id);
    msgResult.fold(
      (failure) => emit(MessagingError(message: failure.message)),
      (messages) {
        emit(ConversationOpened(conversation: conversation, messages: messages));
        _startPolling(conversation.id);
      },
    );
  }

  Future<void> _onLoadMessages(
    LoadMessagesRequested event,
    Emitter<MessagingState> emit,
  ) async {
    if (state is ConversationOpened) {
      final current = state as ConversationOpened;
      final result = await _repository.getMessages(event.conversationId);
      result.fold(
        (_) {},
        (messages) => emit(current.copyWith(messages: messages)),
      );
    }
  }

  Future<void> _onSendMessage(
    SendMessageRequested event,
    Emitter<MessagingState> emit,
  ) async {
    if (state is! ConversationOpened) return;
    final current = state as ConversationOpened;
    emit(current.copyWith(isSending: true));

    final result = await _repository.sendMessage(
      conversationId: event.conversationId,
      content: event.content,
    );

    result.fold(
      (failure) => emit(current.copyWith(isSending: false)),
      (message) {
        final updated = List.of(current.messages)..add(message);
        emit(current.copyWith(messages: updated, isSending: false));
      },
    );
  }

  Future<void> _onMarkAsRead(
    MarkConversationAsRead event,
    Emitter<MessagingState> emit,
  ) async {
    await _repository.markAsRead(event.conversationId);
  }

  Future<void> _onPollMessages(
    PollMessagesRequested event,
    Emitter<MessagingState> emit,
  ) async {
    if (state is ConversationOpened) {
      final current = state as ConversationOpened;
      final result = await _repository.getMessages(event.conversationId);
      result.fold(
        (_) {},
        (messages) {
          if (messages.length != current.messages.length) {
            emit(current.copyWith(messages: messages));
          }
        },
      );
    }
  }

  @override
  Future<void> close() {
    _stopPolling();
    return super.close();
  }
}
