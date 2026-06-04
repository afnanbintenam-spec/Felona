import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/messaging/domain/entities/conversation.dart';
import 'package:felo_na/features/messaging/domain/entities/message.dart';
import 'package:felo_na/features/messaging/domain/repositories/messaging_repository.dart';
import 'package:felo_na/features/messaging/presentation/bloc/messaging_bloc.dart';
import 'package:felo_na/features/messaging/presentation/bloc/messaging_event.dart';
import 'package:felo_na/features/messaging/presentation/bloc/messaging_state.dart';

import 'messaging_bloc_test.mocks.dart';

@GenerateMocks([MessagingRepository])
void main() {
  late MockMessagingRepository repository;
  late MessagingBloc bloc;

  // ─── fixtures ─────────────────────────────────────────────────
  final tDate = DateTime.utc(2024, 5, 1, 10, 0);

  final tConversation = Conversation(
    id: 'conv1',
    listingId: 'l1',
    listingTitle: 'Old Bike',
    listingPrice: 120.0,
    buyerId: 'buyer1',
    buyerName: 'Alice',
    sellerId: 'seller1',
    sellerName: 'Bob',
    createdAt: tDate,
  );

  final tConversation2 = Conversation(
    id: 'conv2',
    listingId: 'l2',
    listingTitle: 'Red Hat',
    listingPrice: 15.0,
    buyerId: 'buyer1',
    buyerName: 'Alice',
    sellerId: 'seller2',
    sellerName: 'Carol',
    createdAt: tDate,
  );

  Message makeMessage({
    String id = 'm1',
    String content = 'Hello!',
    MessageStatus status = MessageStatus.sent,
  }) =>
      Message(
        id: id,
        conversationId: 'conv1',
        senderId: 'buyer1',
        senderName: 'Alice',
        content: content,
        status: status,
        createdAt: tDate,
      );

  final tMessages = [makeMessage(id: 'm1'), makeMessage(id: 'm2', content: 'World')];

  const tServerFailure = ServerFailure('Server error');
  const tNetworkFailure = NetworkFailure('No internet');

  setUp(() {
    repository = MockMessagingRepository();
    bloc = MessagingBloc(repository: repository);
  });

  tearDown(() => bloc.close());

  // ─────────────────────────────────────────────────────────────
  // Initial state
  // ─────────────────────────────────────────────────────────────
  test('initial state is MessagingInitial', () {
    expect(bloc.state, const MessagingInitial());
  });

  // ═════════════════════════════════════════════════════════════
  // LoadConversationsRequested — loading / empty / failures
  // ═════════════════════════════════════════════════════════════
  group('LoadConversationsRequested', () {
    group('loading', () {
      blocTest<MessagingBloc, MessagingState>(
        'emits [Loading, ConversationsLoaded] on success',
        build: () {
          when(repository.getConversations())
              .thenAnswer((_) async => Right([tConversation, tConversation2]));
          return bloc;
        },
        act: (b) => b.add(const LoadConversationsRequested()),
        expect: () => [
          const MessagingLoading(),
          ConversationsLoaded(conversations: [tConversation, tConversation2]),
        ],
      );

      blocTest<MessagingBloc, MessagingState>(
        'always emits Loading first',
        build: () {
          when(repository.getConversations())
              .thenAnswer((_) async => Right([tConversation]));
          return bloc;
        },
        act: (b) => b.add(const LoadConversationsRequested()),
        expect: () => [isA<MessagingLoading>(), isA<ConversationsLoaded>()],
      );
    });

    group('empty states', () {
      blocTest<MessagingBloc, MessagingState>(
        'emits ConversationsLoaded with empty list when API returns []',
        build: () {
          when(repository.getConversations())
              .thenAnswer((_) async => const Right([]));
          return bloc;
        },
        act: (b) => b.add(const LoadConversationsRequested()),
        expect: () => [
          const MessagingLoading(),
          const ConversationsLoaded(conversations: []),
        ],
      );
    });

    group('failures', () {
      blocTest<MessagingBloc, MessagingState>(
        'emits [Loading, Error] on ServerFailure',
        build: () {
          when(repository.getConversations())
              .thenAnswer((_) async => const Left(tServerFailure));
          return bloc;
        },
        act: (b) => b.add(const LoadConversationsRequested()),
        expect: () => [
          const MessagingLoading(),
          const MessagingError(message: 'Server error'),
        ],
      );

      blocTest<MessagingBloc, MessagingState>(
        'emits [Loading, Error] on NetworkFailure',
        build: () {
          when(repository.getConversations())
              .thenAnswer((_) async => const Left(tNetworkFailure));
          return bloc;
        },
        act: (b) => b.add(const LoadConversationsRequested()),
        expect: () => [
          const MessagingLoading(),
          const MessagingError(message: 'No internet'),
        ],
      );

      blocTest<MessagingBloc, MessagingState>(
        'error message is propagated correctly',
        build: () {
          when(repository.getConversations()).thenAnswer(
            (_) async => const Left(ServerFailure('Custom error')),
          );
          return bloc;
        },
        act: (b) => b.add(const LoadConversationsRequested()),
        expect: () => [
          const MessagingLoading(),
          const MessagingError(message: 'Custom error'),
        ],
      );
    });
  });

  // ═════════════════════════════════════════════════════════════
  // OpenConversationRequested — conversation creation
  // ═════════════════════════════════════════════════════════════
  group('OpenConversationRequested', () {
    group('conversation creation', () {
      blocTest<MessagingBloc, MessagingState>(
        'emits [OpeningConversation, ConversationOpened] on success',
        build: () {
          when(repository.getOrCreateConversation(
            listingId: 'l1',
            sellerId: 'seller1',
          )).thenAnswer((_) async => Right(tConversation));
          when(repository.getMessages('conv1'))
              .thenAnswer((_) async => Right(tMessages));
          return bloc;
        },
        act: (b) => b.add(const OpenConversationRequested(
          listingId: 'l1',
          sellerId: 'seller1',
          listingTitle: 'Old Bike',
        )),
        expect: () => [
          const OpeningConversation(),
          ConversationOpened(conversation: tConversation, messages: tMessages),
        ],
      );

      blocTest<MessagingBloc, MessagingState>(
        'ConversationOpened contains correct conversation and messages',
        build: () {
          when(repository.getOrCreateConversation(
            listingId: 'l1',
            sellerId: 'seller1',
          )).thenAnswer((_) async => Right(tConversation));
          when(repository.getMessages('conv1'))
              .thenAnswer((_) async => Right(tMessages));
          return bloc;
        },
        act: (b) => b.add(const OpenConversationRequested(
          listingId: 'l1',
          sellerId: 'seller1',
          listingTitle: 'Old Bike',
        )),
        verify: (b) {
          final s = b.state as ConversationOpened;
          expect(s.conversation.id, 'conv1');
          expect(s.messages.length, 2);
          expect(s.isSending, isFalse);
        },
      );

      blocTest<MessagingBloc, MessagingState>(
        'ConversationOpened with empty messages when API returns []',
        build: () {
          when(repository.getOrCreateConversation(
            listingId: 'l1',
            sellerId: 'seller1',
          )).thenAnswer((_) async => Right(tConversation));
          when(repository.getMessages('conv1'))
              .thenAnswer((_) async => const Right([]));
          return bloc;
        },
        act: (b) => b.add(const OpenConversationRequested(
          listingId: 'l1',
          sellerId: 'seller1',
          listingTitle: 'Old Bike',
        )),
        verify: (b) {
          final s = b.state as ConversationOpened;
          expect(s.messages, isEmpty);
        },
      );
    });

    group('failures', () {
      blocTest<MessagingBloc, MessagingState>(
        'emits [OpeningConversation, Error] when getOrCreateConversation fails',
        build: () {
          when(repository.getOrCreateConversation(
            listingId: anyNamed('listingId'),
            sellerId: anyNamed('sellerId'),
          )).thenAnswer((_) async => const Left(tServerFailure));
          return bloc;
        },
        act: (b) => b.add(const OpenConversationRequested(
          listingId: 'l1',
          sellerId: 'seller1',
          listingTitle: 'Old Bike',
        )),
        expect: () => [
          const OpeningConversation(),
          const MessagingError(message: 'Server error'),
        ],
      );

      blocTest<MessagingBloc, MessagingState>(
        'emits [OpeningConversation, Error] when getMessages fails after conversation created',
        build: () {
          when(repository.getOrCreateConversation(
            listingId: 'l1',
            sellerId: 'seller1',
          )).thenAnswer((_) async => Right(tConversation));
          when(repository.getMessages('conv1'))
              .thenAnswer((_) async => const Left(tServerFailure));
          return bloc;
        },
        act: (b) => b.add(const OpenConversationRequested(
          listingId: 'l1',
          sellerId: 'seller1',
          listingTitle: 'Old Bike',
        )),
        expect: () => [
          const OpeningConversation(),
          const MessagingError(message: 'Server error'),
        ],
      );
    });
  });

  // ═════════════════════════════════════════════════════════════
  // SendMessageRequested — message sending
  // ═════════════════════════════════════════════════════════════
  group('SendMessageRequested', () {
    final openedState = ConversationOpened(
      conversation: tConversation,
      messages: tMessages,
    );

    group('message sending', () {
      final tNewMessage = makeMessage(id: 'm3', content: 'New msg');

      blocTest<MessagingBloc, MessagingState>(
        'emits isSending=true then appends message on success',
        build: () {
          when(repository.sendMessage(
            conversationId: 'conv1',
            content: 'New msg',
          )).thenAnswer((_) async => Right(tNewMessage));
          return bloc;
        },
        seed: () => openedState,
        act: (b) => b.add(const SendMessageRequested(
          conversationId: 'conv1',
          content: 'New msg',
        )),
        expect: () => [
          openedState.copyWith(isSending: true),
          openedState.copyWith(
            messages: [...tMessages, tNewMessage],
            isSending: false,
          ),
        ],
      );

      blocTest<MessagingBloc, MessagingState>(
        'new message is appended at the end of the list',
        build: () {
          when(repository.sendMessage(
            conversationId: 'conv1',
            content: 'Hey',
          )).thenAnswer((_) async => Right(makeMessage(id: 'm3', content: 'Hey')));
          return bloc;
        },
        seed: () => openedState,
        act: (b) => b.add(const SendMessageRequested(
          conversationId: 'conv1',
          content: 'Hey',
        )),
        verify: (b) {
          final s = b.state as ConversationOpened;
          expect(s.messages.last.content, 'Hey');
          expect(s.messages.length, 3);
          expect(s.isSending, isFalse);
        },
      );
    });

    group('failures', () {
      blocTest<MessagingBloc, MessagingState>(
        'resets isSending to false on send failure',
        build: () {
          when(repository.sendMessage(
            conversationId: anyNamed('conversationId'),
            content: anyNamed('content'),
          )).thenAnswer((_) async => const Left(tServerFailure));
          return bloc;
        },
        seed: () => openedState,
        act: (b) => b.add(const SendMessageRequested(
          conversationId: 'conv1',
          content: 'fail',
        )),
        expect: () => [
          openedState.copyWith(isSending: true),
          openedState.copyWith(isSending: false),
        ],
      );

      blocTest<MessagingBloc, MessagingState>(
        'does not add message to list on send failure',
        build: () {
          when(repository.sendMessage(
            conversationId: anyNamed('conversationId'),
            content: anyNamed('content'),
          )).thenAnswer((_) async => const Left(tServerFailure));
          return bloc;
        },
        seed: () => openedState,
        act: (b) => b.add(const SendMessageRequested(
          conversationId: 'conv1',
          content: 'fail',
        )),
        verify: (b) {
          final s = b.state as ConversationOpened;
          expect(s.messages.length, tMessages.length);
        },
      );

      blocTest<MessagingBloc, MessagingState>(
        'does nothing when state is NOT ConversationOpened',
        build: () => bloc,
        seed: () => const MessagingInitial(),
        act: (b) => b.add(const SendMessageRequested(
          conversationId: 'conv1',
          content: 'Hi',
        )),
        expect: () => <MessagingState>[],
        verify: (_) => verifyNever(repository.sendMessage(
          conversationId: anyNamed('conversationId'),
          content: anyNamed('content'),
        )),
      );
    });
  });

  // ═════════════════════════════════════════════════════════════
  // LoadMessagesRequested
  // ═════════════════════════════════════════════════════════════
  group('LoadMessagesRequested', () {
    final openedState = ConversationOpened(
      conversation: tConversation,
      messages: tMessages,
    );

    blocTest<MessagingBloc, MessagingState>(
      'updates messages when state is ConversationOpened',
      build: () {
        final newMessages = [...tMessages, makeMessage(id: 'm3')];
        when(repository.getMessages('conv1'))
            .thenAnswer((_) async => Right(newMessages));
        return bloc;
      },
      seed: () => openedState,
      act: (b) =>
          b.add(const LoadMessagesRequested(conversationId: 'conv1')),
      verify: (b) {
        final s = b.state as ConversationOpened;
        expect(s.messages.length, 3);
      },
    );

    blocTest<MessagingBloc, MessagingState>(
      'does nothing when state is NOT ConversationOpened',
      build: () => bloc,
      seed: () => const MessagingInitial(),
      act: (b) =>
          b.add(const LoadMessagesRequested(conversationId: 'conv1')),
      expect: () => <MessagingState>[],
      verify: (_) => verifyNever(repository.getMessages(any)),
    );

    blocTest<MessagingBloc, MessagingState>(
      'silently ignores message load failure',
      build: () {
        when(repository.getMessages('conv1'))
            .thenAnswer((_) async => const Left(tServerFailure));
        return bloc;
      },
      seed: () => openedState,
      act: (b) =>
          b.add(const LoadMessagesRequested(conversationId: 'conv1')),
      expect: () => <MessagingState>[],
    );
  });

  // ═════════════════════════════════════════════════════════════
  // PollMessagesRequested
  // ═════════════════════════════════════════════════════════════
  group('PollMessagesRequested', () {
    final openedState = ConversationOpened(
      conversation: tConversation,
      messages: tMessages,
    );

    blocTest<MessagingBloc, MessagingState>(
      'emits updated state when new messages arrive (length changed)',
      build: () {
        final more = [...tMessages, makeMessage(id: 'm3')];
        when(repository.getMessages('conv1'))
            .thenAnswer((_) async => Right(more));
        return bloc;
      },
      seed: () => openedState,
      act: (b) =>
          b.add(const PollMessagesRequested(conversationId: 'conv1')),
      verify: (b) {
        expect((b.state as ConversationOpened).messages.length, 3);
      },
    );

    blocTest<MessagingBloc, MessagingState>(
      'does NOT emit new state when message count unchanged',
      build: () {
        when(repository.getMessages('conv1'))
            .thenAnswer((_) async => Right(tMessages));
        return bloc;
      },
      seed: () => openedState,
      act: (b) =>
          b.add(const PollMessagesRequested(conversationId: 'conv1')),
      expect: () => <MessagingState>[],
    );

    blocTest<MessagingBloc, MessagingState>(
      'does nothing when state is NOT ConversationOpened',
      build: () => bloc,
      seed: () => const MessagingInitial(),
      act: (b) =>
          b.add(const PollMessagesRequested(conversationId: 'conv1')),
      expect: () => <MessagingState>[],
      verify: (_) => verifyNever(repository.getMessages(any)),
    );
  });

  // ═════════════════════════════════════════════════════════════
  // MarkConversationAsRead
  // ═════════════════════════════════════════════════════════════
  group('MarkConversationAsRead', () {
    blocTest<MessagingBloc, MessagingState>(
      'calls repository.markAsRead with correct conversationId',
      build: () {
        when(repository.markAsRead('conv1'))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (b) =>
          b.add(const MarkConversationAsRead(conversationId: 'conv1')),
      verify: (_) => verify(repository.markAsRead('conv1')).called(1),
    );

    blocTest<MessagingBloc, MessagingState>(
      'does NOT emit new state (mark-as-read is side-effect only)',
      build: () {
        when(repository.markAsRead(any))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (b) =>
          b.add(const MarkConversationAsRead(conversationId: 'conv1')),
      expect: () => <MessagingState>[],
    );
  });

  // ═════════════════════════════════════════════════════════════
  // State equality
  // ═════════════════════════════════════════════════════════════
  group('State equality', () {
    test('MessagingInitial equals MessagingInitial', () {
      expect(const MessagingInitial(), const MessagingInitial());
    });

    test('MessagingLoading equals MessagingLoading', () {
      expect(const MessagingLoading(), const MessagingLoading());
    });

    test('OpeningConversation equals OpeningConversation', () {
      expect(const OpeningConversation(), const OpeningConversation());
    });

    test('ConversationsLoaded equals with same conversations', () {
      final a = ConversationsLoaded(conversations: [tConversation]);
      final b = ConversationsLoaded(conversations: [tConversation]);
      expect(a, equals(b));
    });

    test('ConversationOpened equals with same data', () {
      final a = ConversationOpened(
          conversation: tConversation, messages: tMessages);
      final b = ConversationOpened(
          conversation: tConversation, messages: tMessages);
      expect(a, equals(b));
    });

    test('MessagingError equals with same message', () {
      expect(
        const MessagingError(message: 'err'),
        const MessagingError(message: 'err'),
      );
    });

    test('ConversationOpened.copyWith updates isSending', () {
      final original = ConversationOpened(
          conversation: tConversation, messages: tMessages);
      final copy = original.copyWith(isSending: true);
      expect(copy.isSending, isTrue);
      expect(copy.messages, tMessages);
    });
  });

  // ═════════════════════════════════════════════════════════════
  // Repository interaction verification
  // ═════════════════════════════════════════════════════════════
  group('Repository interaction', () {
    blocTest<MessagingBloc, MessagingState>(
      'LoadConversationsRequested calls getConversations once',
      build: () {
        when(repository.getConversations())
            .thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (b) => b.add(const LoadConversationsRequested()),
      verify: (_) => verify(repository.getConversations()).called(1),
    );

    blocTest<MessagingBloc, MessagingState>(
      'OpenConversationRequested calls both getOrCreateConversation and getMessages',
      build: () {
        when(repository.getOrCreateConversation(
          listingId: 'l1',
          sellerId: 'seller1',
        )).thenAnswer((_) async => Right(tConversation));
        when(repository.getMessages('conv1'))
            .thenAnswer((_) async => Right(tMessages));
        return bloc;
      },
      act: (b) => b.add(const OpenConversationRequested(
        listingId: 'l1',
        sellerId: 'seller1',
        listingTitle: 'Old Bike',
      )),
      verify: (_) {
        verify(repository.getOrCreateConversation(
          listingId: 'l1',
          sellerId: 'seller1',
        )).called(1);
        verify(repository.getMessages('conv1')).called(1);
      },
    );
  });
}
