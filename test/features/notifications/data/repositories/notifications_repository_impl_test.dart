import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/errors/exceptions.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:felo_na/features/notifications/data/models/notification_model.dart';
import 'package:felo_na/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:felo_na/features/notifications/domain/entities/notification.dart';

import 'notifications_repository_impl_test.mocks.dart';

@GenerateMocks([NotificationsRemoteDataSource])
void main() {
  late MockNotificationsRemoteDataSource remoteDataSource;
  late NotificationsRepositoryImpl repository;

  // ─── fixtures ─────────────────────────────────────────────────
  final tDate = DateTime.utc(2024, 5, 1);

  NotificationModel makeModel({String id = 'n1', bool isRead = false}) =>
      NotificationModel(
        id: id,
        userId: 'u1',
        type: NotificationType.general,
        title: 'Title',
        message: 'Message',
        isRead: isRead,
        createdAt: tDate,
      );

  final tModels = [makeModel(id: 'n1'), makeModel(id: 'n2', isRead: true)];

  setUp(() {
    remoteDataSource = MockNotificationsRemoteDataSource();
    repository =
        NotificationsRepositoryImpl(remoteDataSource: remoteDataSource);
  });

  // ═════════════════════════════════════════════════════════════
  // getNotifications
  // ═════════════════════════════════════════════════════════════
  group('getNotifications', () {
    group('loading', () {
      test('returns Right(List<AppNotification>) on success', () async {
        when(remoteDataSource.getNotifications())
            .thenAnswer((_) async => tModels);

        final result = await repository.getNotifications();

        expect(result, isA<Right>());
        result.fold((_) => fail('Expected Right'), (list) {
          expect(list.length, 2);
          expect(list.first, isA<AppNotification>());
        });
      });

      test('returned items are AppNotification instances', () async {
        when(remoteDataSource.getNotifications())
            .thenAnswer((_) async => tModels);
        final result = await repository.getNotifications();
        final list = result.getOrElse(() => throw Exception());
        expect(list.every((n) => n is AppNotification), isTrue);
      });
    });

    group('empty states', () {
      test('returns Right([]) when API returns empty list', () async {
        when(remoteDataSource.getNotifications())
            .thenAnswer((_) async => []);
        final result = await repository.getNotifications();
        result.fold(
          (_) => fail('Expected Right'),
          (list) => expect(list, isEmpty),
        );
      });
    });

    group('failures', () {
      test('returns Left(ServerFailure) on ServerException', () async {
        when(remoteDataSource.getNotifications())
            .thenThrow(const ServerException('Server error', 500));
        final result = await repository.getNotifications();
        result.fold(
          (f) => expect(f, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });

      test('returns Left(NetworkFailure) on NetworkException', () async {
        when(remoteDataSource.getNotifications())
            .thenThrow(const NetworkException('No internet'));
        final result = await repository.getNotifications();
        result.fold(
          (f) => expect(f, isA<NetworkFailure>()),
          (_) => fail('Expected Left'),
        );
      });

      test('never throws — always returns Either', () async {
        when(remoteDataSource.getNotifications())
            .thenThrow(Exception('unexpected'));
        expect(() async => repository.getNotifications(), returnsNormally);
      });
    });
  });

  // ═════════════════════════════════════════════════════════════
  // markAsRead — read operations
  // ═════════════════════════════════════════════════════════════
  group('markAsRead', () {
    group('read operations', () {
      test('returns Right(null) on success', () async {
        when(remoteDataSource.markAsRead('n1'))
            .thenAnswer((_) async {});
        final result = await repository.markAsRead('n1');
        expect(result, isA<Right>());
      });

      test('passes notificationId to data source', () async {
        when(remoteDataSource.markAsRead('n42'))
            .thenAnswer((_) async {});
        await repository.markAsRead('n42');
        verify(remoteDataSource.markAsRead('n42')).called(1);
      });
    });

    group('failures', () {
      test('returns Left on ServerException', () async {
        when(remoteDataSource.markAsRead(any))
            .thenThrow(const ServerException('Server error'));
        final result = await repository.markAsRead('n1');
        result.fold(
          (f) => expect(f, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });

      test('never throws — always returns Either', () async {
        when(remoteDataSource.markAsRead(any)).thenThrow(Exception('boom'));
        expect(() async => repository.markAsRead('n1'), returnsNormally);
      });
    });
  });

  // ═════════════════════════════════════════════════════════════
  // markAllAsRead — read operations
  // ═════════════════════════════════════════════════════════════
  group('markAllAsRead', () {
    group('read operations', () {
      test('returns Right(null) on success', () async {
        when(remoteDataSource.markAllAsRead()).thenAnswer((_) async {});
        final result = await repository.markAllAsRead();
        expect(result, isA<Right>());
      });

      test('calls data source once', () async {
        when(remoteDataSource.markAllAsRead()).thenAnswer((_) async {});
        await repository.markAllAsRead();
        verify(remoteDataSource.markAllAsRead()).called(1);
      });
    });

    group('failures', () {
      test('returns Left on ServerException', () async {
        when(remoteDataSource.markAllAsRead())
            .thenThrow(const ServerException('Server error'));
        final result = await repository.markAllAsRead();
        result.fold(
          (f) => expect(f, isA<Failure>()),
          (_) => fail('Expected Left'),
        );
      });
    });
  });

  // ═════════════════════════════════════════════════════════════
  // deleteNotification
  // ═════════════════════════════════════════════════════════════
  group('deleteNotification', () {
    test('returns Right(null) on success', () async {
      when(remoteDataSource.deleteNotification('n1'))
          .thenAnswer((_) async {});
      final result = await repository.deleteNotification('n1');
      expect(result, isA<Right>());
    });

    test('passes id to data source', () async {
      when(remoteDataSource.deleteNotification('n7'))
          .thenAnswer((_) async {});
      await repository.deleteNotification('n7');
      verify(remoteDataSource.deleteNotification('n7')).called(1);
    });

    test('returns Left on failure', () async {
      when(remoteDataSource.deleteNotification(any))
          .thenThrow(const ServerException('Failed'));
      final result = await repository.deleteNotification('n1');
      expect(result, isA<Left>());
    });
  });

  // ═════════════════════════════════════════════════════════════
  // registerFcmToken — FCM registration
  // ═════════════════════════════════════════════════════════════
  group('registerFcmToken', () {
    group('FCM registration', () {
      test('returns Right(null) on success', () async {
        when(remoteDataSource.registerFcmToken('tok'))
            .thenAnswer((_) async {});
        final result = await repository.registerFcmToken('tok');
        expect(result, isA<Right>());
      });

      test('passes token to data source', () async {
        when(remoteDataSource.registerFcmToken('my-device-token'))
            .thenAnswer((_) async {});
        await repository.registerFcmToken('my-device-token');
        verify(remoteDataSource.registerFcmToken('my-device-token')).called(1);
      });

      test('returns Left(ServerFailure) on ServerException', () async {
        when(remoteDataSource.registerFcmToken(any))
            .thenThrow(const ServerException('FCM error', 500));
        final result = await repository.registerFcmToken('tok');
        result.fold(
          (f) => expect(f, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });

      test('returns Left(NetworkFailure) on NetworkException', () async {
        when(remoteDataSource.registerFcmToken(any))
            .thenThrow(const NetworkException('No internet'));
        final result = await repository.registerFcmToken('tok');
        result.fold(
          (f) => expect(f, isA<NetworkFailure>()),
          (_) => fail('Expected Left'),
        );
      });

      test('never throws — always returns Either', () async {
        when(remoteDataSource.registerFcmToken(any))
            .thenThrow(Exception('unexpected'));
        expect(
          () async => repository.registerFcmToken('tok'),
          returnsNormally,
        );
      });
    });
  });
}
