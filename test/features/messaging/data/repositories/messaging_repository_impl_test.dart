import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/errors/exceptions.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/messaging/data/datasources/messaging_remote_data_source.dart';
import 'package:felo_na/features/messaging/data/models/conversation_model.dart';
import 'package:felo_na/features/messaging/data/models/message_model.dart';
import 'package:felo_na/features/messaging/data/repositories/messaging_repository_impl.dart';
import 'package:felo_na/features/messaging/domain/entities/conversation.dart';
import 'package:felo_na/features/messaging/domain/entities/message.dart';

import 'messaging_repository_impl_test.mocks.dart';

@GenerateMocks([MessagingRemoteDataSource])
void main() {
  late MockMessagingRemoteDataSource remoteDataSource;
  late MessagingRepositoryImpl repository;

  // ─── fixtures ─────────────────────────────────────────────────
  final tDate = DateTime.utc(2024, 5, 1);

  final tConvModel = ConversationModel(
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

  final tMsgModel = MessageModel(
    id: 'm1',
    conversationId: 'conv1',
    senderId: 'buyer1',
    senderName: 'Alice',
    content: 'Hello!',
    status: MessageStatus.sent,
    createdAt: tDate,
  );

  setUp(() {
    remoteDataSource = MockMessagingRemoteDataSource();
    repository = MessagingRepositoryImpl(remoteDataSource: remoteDataSource);
  });

  // ═════════════════════════════════════════════════════════════
  // getConversations — loading / empty / failures
  // ═════════════════════════════════════════════════════════════
  group('getConversations', () {
    group('loading', () {
      test('returns Right(List<Conversation>) on success', () async {
        when(remoteDataSource.getConversations())
            .thenAnswer((_) async => [tConvModel]);
        final result = await repository.getConversations();
        expect(result, isA<Right>());
        result.fold((_) => fail('Expected Right'), (list) {
          expect(list.length, 1);
          expect(list.first, isA<Conversation>());
        });
      });
    });

    group('empty states', () {
      test('returns Right([]) when API returns empty list', () async {
        when(remoteDataSource.getConversations())
            .thenAnswer((_) async => []);
        final result = await repository.getConversations();
        result.fold(
          (_) => fail('Expected Right'),
          (list) => expect(list, isEmpty),
        );
      });
    });

    group('failures', () {
      test('returns Left(ServerFailure) on ServerException', () async {
        when(remoteDataSource.getConversations())
            .thenThrow(const ServerException('Server error', 500));
        final result = await repository.getConversations();
        result.fold(
          (f) => expect(f, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });

      test('returns Left(NetworkFailure) on NetworkException', () async {
        when(remoteDataSource.getConversations())
            .thenThrow(const NetworkException('No internet'));
        final result = await repository.getConversations();
        result.fold(
          (f) => expect(f, isA<NetworkFailure>()),
          (_) => fail('Expected Left'),
        );
      });

      test('returns Left(ServerFailure) on generic Exception', () async {
        when(remoteDataSource.getConversations())
            .thenThrow(Exception('unexpected'));
        final result = await repository.getConversations();
        result.fold(
          (f) => expect(f, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });

      test('never throws — always returns Either', () async {
        when(remoteDataSource.getConversations())
            .thenThrow(Exception('boom'));
        expect(
          () async => repository.getConversations(),
          returnsNormally,
        );
      });
    });
  });

  // ═════════════════════════════════════════════════════════════
  // getMessages — loading / empty / failures
  // ═════════════════════════════════════════════════════════════
  group('getMessages', () {
    group('loading', () {
      test('returns Right(List<Message>) on success', () async {
        when(remoteDataSource.getMessages('conv1'))
            .thenAnswer((_) async => [tMsgModel]);
        final result = await repository.getMessages('conv1');
        result.fold((_) => fail('Expected Right'), (list) {
          expect(list.length, 1);
          expect(list.first, isA<Message>());
        });
      });

      test('passes conversationId to data source', () async {
        when(remoteDataSource.getMessages('conv42'))
            .thenAnswer((_) async => []);
        await repository.getMessages('conv42');
        verify(remoteDataSource.getMessages('conv42')).called(1);
      });
    });

    group('empty states', () {
      test('returns Right([]) when API returns no messages', () async {
        when(remoteDataSource.getMessages('conv1'))
            .thenAnswer((_) async => []);
        final result = await repository.getMessages('conv1');
        result.fold(
          (_) => fail('Expected Right'),
          (list) => expect(list, isEmpty),
        );
      });
    });

    group('failures', () {
      test('returns Left on ServerException', () async {
        when(remoteDataSource.getMessages(any))
            .thenThrow(const ServerException('Error'));
        final result = await repository.getMessages('conv1');
        expect(result, isA<Left>());
      });

      test('returns Left on NetworkException', () async {
        when(remoteDataSource.getMessages(any))
            .thenThrow(const NetworkException('No internet'));
        final result = await repository.getMessages('conv1');
        result.fold(
          (f) => expect(f, isA<NetworkFailure>()),
          (_) => fail('Expected Left'),
        );
      });

      test('never throws — always returns Either', () async {
        when(remoteDataSource.getMessages(any)).thenThrow(Exception('boom'));
        expect(() async => repository.getMessages('conv1'), returnsNormally);
      });
    });
  });

  // ═════════════════════════════════════════════════════════════
  // getOrCreateConversation — conversation creation
  // ═════════════════════════════════════════════════════════════
  group('getOrCreateConversation', () {
    group('conversation creation', () {
      test('returns Right(Conversation) on success', () async {
        when(remoteDataSource.getOrCreateConversation(
          listingId: 'l1',
          sellerId: 'seller1',
        )).thenAnswer((_) async => tConvModel);

        final result = await repository.getOrCreateConversation(
          listingId: 'l1',
          sellerId: 'seller1',
        );

        expect(result, isA<Right>());
        result.fold((_) => fail('Expected Right'), (conv) {
          expect(conv.id, 'conv1');
          expect(conv, isA<Conversation>());
        });
      });

      test('passes listingId and sellerId to data source', () async {
        when(remoteDataSource.getOrCreateConversation(
          listingId: 'l99',
          sellerId: 's99',
        )).thenAnswer((_) async => tConvModel);

        await repository.getOrCreateConversation(
          listingId: 'l99',
          sellerId: 's99',
        );

        verify(remoteDataSource.getOrCreateConversation(
          listingId: 'l99',
          sellerId: 's99',
        )).called(1);
      });
    });

    group('failures', () {
      test('returns Left(ServerFailure) on ServerException', () async {
        when(remoteDataSource.getOrCreateConversation(
          listingId: anyNamed('listingId'),
          sellerId: anyNamed('sellerId'),
        )).thenThrow(const ServerException('Server error', 500));

        final result = await repository.getOrCreateConversation(
          listingId: 'l1',
          sellerId: 's1',
        );

        result.fold(
          (f) => expect(f, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });

      test('returns Left(NetworkFailure) on NetworkException', () async {
        when(remoteDataSource.getOrCreateConversation(
          listingId: anyNamed('listingId'),
          sellerId: anyNamed('sellerId'),
        )).thenThrow(const NetworkException('No internet'));

        final result = await repository.getOrCreateConversation(
          listingId: 'l1',
          sellerId: 's1',
        );

        result.fold(
          (f) => expect(f, isA<NetworkFailure>()),
          (_) => fail('Expected Left'),
        );
      });

      test('never throws — always returns Either', () async {
        when(remoteDataSource.getOrCreateConversation(
          listingId: anyNamed('listingId'),
          sellerId: anyNamed('sellerId'),
        )).thenThrow(Exception('boom'));

        expect(
          () async => repository.getOrCreateConversation(
            listingId: 'l1',
            sellerId: 's1',
          ),
          returnsNormally,
        );
      });
    });
  });

  // ═════════════════════════════════════════════════════════════
  // sendMessage — message sending
  // ═════════════════════════════════════════════════════════════
  group('sendMessage', () {
    group('message sending', () {
      test('returns Right(Message) on success', () async {
        when(remoteDataSource.sendMessage(
          conversationId: 'conv1',
          content: 'Hello!',
        )).thenAnswer((_) async => tMsgModel);

        final result = await repository.sendMessage(
          conversationId: 'conv1',
          content: 'Hello!',
        );

        expect(result, isA<Right>());
        result.fold((_) => fail('Expected Right'), (msg) {
          expect(msg.content, 'Hello!');
          expect(msg, isA<Message>());
        });
      });

      test('passes conversationId and content to data source', () async {
        when(remoteDataSource.sendMessage(
          conversationId: 'conv5',
          content: 'Test',
        )).thenAnswer((_) async => tMsgModel);

        await repository.sendMessage(
          conversationId: 'conv5',
          content: 'Test',
        );

        verify(remoteDataSource.sendMessage(
          conversationId: 'conv5',
          content: 'Test',
        )).called(1);
      });
    });

    group('failures', () {
      test('returns Left(ServerFailure) on ServerException', () async {
        when(remoteDataSource.sendMessage(
          conversationId: anyNamed('conversationId'),
          content: anyNamed('content'),
        )).thenThrow(const ServerException('Send failed', 500));

        final result = await repository.sendMessage(
          conversationId: 'conv1',
          content: 'test',
        );

        result.fold(
          (f) => expect(f, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });

      test('returns Left(NetworkFailure) on NetworkException', () async {
        when(remoteDataSource.sendMessage(
          conversationId: anyNamed('conversationId'),
          content: anyNamed('content'),
        )).thenThrow(const NetworkException('No internet'));

        final result = await repository.sendMessage(
          conversationId: 'conv1',
          content: 'test',
        );

        result.fold(
          (f) => expect(f, isA<NetworkFailure>()),
          (_) => fail('Expected Left'),
        );
      });

      test('never throws — always returns Either', () async {
        when(remoteDataSource.sendMessage(
          conversationId: anyNamed('conversationId'),
          content: anyNamed('content'),
        )).thenThrow(Exception('boom'));

        expect(
          () async => repository.sendMessage(
            conversationId: 'conv1',
            content: 'test',
          ),
          returnsNormally,
        );
      });
    });
  });

  // ═════════════════════════════════════════════════════════════
  // markAsRead
  // ═════════════════════════════════════════════════════════════
  group('markAsRead', () {
    test('returns Right(null) on success', () async {
      when(remoteDataSource.markAsRead('conv1')).thenAnswer((_) async {});
      final result = await repository.markAsRead('conv1');
      expect(result, isA<Right>());
    });

    test('passes conversationId to data source', () async {
      when(remoteDataSource.markAsRead('conv99')).thenAnswer((_) async {});
      await repository.markAsRead('conv99');
      verify(remoteDataSource.markAsRead('conv99')).called(1);
    });

    test('returns Right(null) even when data source throws (silent fail)', () async {
      when(remoteDataSource.markAsRead(any)).thenThrow(Exception('network'));
      final result = await repository.markAsRead('conv1');
      // MessagingRepositoryImpl silently ignores markAsRead errors
      expect(result, isA<Right>());
    });
  });
}
