import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/notifications/domain/entities/notification.dart';
import 'package:felo_na/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:felo_na/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:felo_na/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:felo_na/features/notifications/presentation/bloc/notifications_state.dart';

import 'notifications_bloc_test.mocks.dart';

@GenerateMocks([NotificationsRepository])
void main() {
  late MockNotificationsRepository repository;
  late NotificationsBloc bloc;

  // ─── fixtures ─────────────────────────────────────────────────
  final tDate = DateTime.utc(2024, 5, 1, 10, 0);

  AppNotification makeNotif({
    String id = 'n1',
    bool isRead = false,
    NotificationType type = NotificationType.general,
  }) =>
      AppNotification(
        id: id,
        userId: 'u1',
        type: type,
        title: 'Test title',
        message: 'Test message',
        isRead: isRead,
        createdAt: tDate,
      );

  final tUnread = makeNotif(id: 'n1', isRead: false);
  final tRead = makeNotif(id: 'n2', isRead: true);
  final tList = [tUnread, tRead];

  const tServerFailure = ServerFailure('Server error');
  const tNetworkFailure = NetworkFailure('No internet');

  setUp(() {
    repository = MockNotificationsRepository();
    bloc = NotificationsBloc(repository: repository);
  });

  tearDown(() => bloc.close());

  // ─────────────────────────────────────────────────────────────
  // Initial state
  // ─────────────────────────────────────────────────────────────
  test('initial state is NotificationsInitial', () {
    expect(bloc.state, const NotificationsInitial());
  });

  // ═════════════════════════════════════════════════════════════
  // LoadNotificationsRequested — loading / empty / failures
  // ═════════════════════════════════════════════════════════════
  group('LoadNotificationsRequested', () {
    group('loading', () {
      blocTest<NotificationsBloc, NotificationsState>(
        'emits [Loading, Loaded] on success',
        build: () {
          when(repository.getNotifications())
              .thenAnswer((_) async => Right(tList));
          return bloc;
        },
        act: (b) => b.add(const LoadNotificationsRequested()),
        expect: () => [
          const NotificationsLoading(),
          NotificationsLoaded(notifications: tList, unreadCount: 1),
        ],
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'always emits Loading as first state',
        build: () {
          when(repository.getNotifications())
              .thenAnswer((_) async => Right(tList));
          return bloc;
        },
        act: (b) => b.add(const LoadNotificationsRequested()),
        expect: () => [isA<NotificationsLoading>(), isA<NotificationsLoaded>()],
      );
    });

    group('empty states', () {
      blocTest<NotificationsBloc, NotificationsState>(
        'emits Loaded with empty list and unreadCount=0 when API returns []',
        build: () {
          when(repository.getNotifications())
              .thenAnswer((_) async => const Right([]));
          return bloc;
        },
        act: (b) => b.add(const LoadNotificationsRequested()),
        expect: () => [
          const NotificationsLoading(),
          const NotificationsLoaded(notifications: [], unreadCount: 0),
        ],
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'unreadCount is 0 when all notifications are read',
        build: () {
          final allRead = [
            makeNotif(id: 'n1', isRead: true),
            makeNotif(id: 'n2', isRead: true),
          ];
          when(repository.getNotifications())
              .thenAnswer((_) async => Right(allRead));
          return bloc;
        },
        act: (b) => b.add(const LoadNotificationsRequested()),
        verify: (b) {
          final s = b.state as NotificationsLoaded;
          expect(s.unreadCount, 0);
        },
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'unreadCount equals number of unread notifications',
        build: () {
          final three = [
            makeNotif(id: 'n1', isRead: false),
            makeNotif(id: 'n2', isRead: false),
            makeNotif(id: 'n3', isRead: true),
          ];
          when(repository.getNotifications())
              .thenAnswer((_) async => Right(three));
          return bloc;
        },
        act: (b) => b.add(const LoadNotificationsRequested()),
        verify: (b) {
          expect((b.state as NotificationsLoaded).unreadCount, 2);
        },
      );
    });

    group('failures', () {
      blocTest<NotificationsBloc, NotificationsState>(
        'emits [Loading, Error] on ServerFailure',
        build: () {
          when(repository.getNotifications())
              .thenAnswer((_) async => const Left(tServerFailure));
          return bloc;
        },
        act: (b) => b.add(const LoadNotificationsRequested()),
        expect: () => [
          const NotificationsLoading(),
          const NotificationsError(message: 'Server error'),
        ],
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'emits [Loading, Error] on NetworkFailure',
        build: () {
          when(repository.getNotifications())
              .thenAnswer((_) async => const Left(tNetworkFailure));
          return bloc;
        },
        act: (b) => b.add(const LoadNotificationsRequested()),
        expect: () => [
          const NotificationsLoading(),
          const NotificationsError(message: 'No internet'),
        ],
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'error message is propagated correctly',
        build: () {
          when(repository.getNotifications()).thenAnswer(
            (_) async =>
                const Left(ServerFailure('Custom error message', 503)),
          );
          return bloc;
        },
        act: (b) => b.add(const LoadNotificationsRequested()),
        expect: () => [
          const NotificationsLoading(),
          const NotificationsError(message: 'Custom error message'),
        ],
      );
    });
  });

  // ═════════════════════════════════════════════════════════════
  // MarkNotificationAsReadRequested — read operations
  // ═════════════════════════════════════════════════════════════
  group('MarkNotificationAsReadRequested', () {
    group('read operations', () {
      blocTest<NotificationsBloc, NotificationsState>(
        'emits [MarkedAsRead, Loaded] with optimistic update',
        build: () {
          when(repository.markAsRead('n1'))
              .thenAnswer((_) async => const Right(null));
          return bloc;
        },
        seed: () => NotificationsLoaded(notifications: tList, unreadCount: 1),
        act: (b) =>
            b.add(const MarkNotificationAsReadRequested(notificationId: 'n1')),
        expect: () => [
          const NotificationMarkedAsRead(notificationId: 'n1'),
          isA<NotificationsLoaded>(),
        ],
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'decrements unreadCount after marking a notification read',
        build: () {
          when(repository.markAsRead('n1'))
              .thenAnswer((_) async => const Right(null));
          return bloc;
        },
        seed: () => NotificationsLoaded(notifications: tList, unreadCount: 1),
        act: (b) =>
            b.add(const MarkNotificationAsReadRequested(notificationId: 'n1')),
        verify: (b) {
          final s = b.state as NotificationsLoaded;
          expect(s.unreadCount, 0);
          expect(s.notifications.firstWhere((n) => n.id == 'n1').isRead, isTrue);
        },
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'does nothing when state is NOT NotificationsLoaded',
        build: () => bloc,
        seed: () => const NotificationsInitial(),
        act: (b) =>
            b.add(const MarkNotificationAsReadRequested(notificationId: 'n1')),
        expect: () => <NotificationsState>[],
        verify: (_) => verifyNever(repository.markAsRead(any)),
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'marks only the target notification as read',
        build: () {
          when(repository.markAsRead('n1'))
              .thenAnswer((_) async => const Right(null));
          return bloc;
        },
        seed: () => NotificationsLoaded(
          notifications: [
            makeNotif(id: 'n1', isRead: false),
            makeNotif(id: 'n2', isRead: false),
          ],
          unreadCount: 2,
        ),
        act: (b) =>
            b.add(const MarkNotificationAsReadRequested(notificationId: 'n1')),
        verify: (b) {
          final s = b.state as NotificationsLoaded;
          expect(s.notifications.firstWhere((n) => n.id == 'n1').isRead, isTrue);
          expect(s.notifications.firstWhere((n) => n.id == 'n2').isRead, isFalse);
          expect(s.unreadCount, 1);
        },
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'calls repository.markAsRead with correct id',
        build: () {
          when(repository.markAsRead('n1'))
              .thenAnswer((_) async => const Right(null));
          return bloc;
        },
        seed: () => NotificationsLoaded(notifications: tList, unreadCount: 1),
        act: (b) =>
            b.add(const MarkNotificationAsReadRequested(notificationId: 'n1')),
        verify: (_) => verify(repository.markAsRead('n1')).called(1),
      );
    });
  });

  // ═════════════════════════════════════════════════════════════
  // MarkAllNotificationsAsReadRequested
  // ═════════════════════════════════════════════════════════════
  group('MarkAllNotificationsAsReadRequested', () {
    group('read operations', () {
      blocTest<NotificationsBloc, NotificationsState>(
        'emits [AllMarkedAsRead, Loaded(unread=0)] with optimistic update',
        build: () {
          when(repository.markAllAsRead())
              .thenAnswer((_) async => const Right(null));
          return bloc;
        },
        seed: () =>
            NotificationsLoaded(notifications: tList, unreadCount: 1),
        act: (b) => b.add(const MarkAllNotificationsAsReadRequested()),
        expect: () => [
          const AllNotificationsMarkedAsRead(),
          NotificationsLoaded(
            notifications: tList.map((n) => n.copyWith(isRead: true)).toList(),
            unreadCount: 0,
          ),
        ],
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'all notifications become read after event',
        build: () {
          when(repository.markAllAsRead())
              .thenAnswer((_) async => const Right(null));
          return bloc;
        },
        seed: () => NotificationsLoaded(
          notifications: [
            makeNotif(id: 'n1', isRead: false),
            makeNotif(id: 'n2', isRead: false),
            makeNotif(id: 'n3', isRead: false),
          ],
          unreadCount: 3,
        ),
        act: (b) => b.add(const MarkAllNotificationsAsReadRequested()),
        verify: (b) {
          final s = b.state as NotificationsLoaded;
          expect(s.unreadCount, 0);
          expect(s.notifications.every((n) => n.isRead), isTrue);
        },
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'does nothing when state is NOT NotificationsLoaded',
        build: () => bloc,
        seed: () => const NotificationsInitial(),
        act: (b) => b.add(const MarkAllNotificationsAsReadRequested()),
        expect: () => <NotificationsState>[],
        verify: (_) => verifyNever(repository.markAllAsRead()),
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'calls repository.markAllAsRead once',
        build: () {
          when(repository.markAllAsRead())
              .thenAnswer((_) async => const Right(null));
          return bloc;
        },
        seed: () =>
            NotificationsLoaded(notifications: tList, unreadCount: 1),
        act: (b) => b.add(const MarkAllNotificationsAsReadRequested()),
        verify: (_) => verify(repository.markAllAsRead()).called(1),
      );
    });
  });

  // ═════════════════════════════════════════════════════════════
  // DeleteNotificationRequested
  // ═════════════════════════════════════════════════════════════
  group('DeleteNotificationRequested', () {
    blocTest<NotificationsBloc, NotificationsState>(
      'emits [Deleted, Loaded] removing the notification',
      build: () {
        when(repository.deleteNotification('n1'))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => NotificationsLoaded(notifications: tList, unreadCount: 1),
      act: (b) =>
          b.add(const DeleteNotificationRequested(notificationId: 'n1')),
      expect: () => [
        const NotificationDeleted(notificationId: 'n1'),
        isA<NotificationsLoaded>(),
      ],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'removes notification from list after delete',
      build: () {
        when(repository.deleteNotification('n1'))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => NotificationsLoaded(notifications: tList, unreadCount: 1),
      act: (b) =>
          b.add(const DeleteNotificationRequested(notificationId: 'n1')),
      verify: (b) {
        final s = b.state as NotificationsLoaded;
        expect(s.notifications.any((n) => n.id == 'n1'), isFalse);
        expect(s.notifications.length, 1);
      },
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'recalculates unreadCount after deleting an unread notification',
      build: () {
        when(repository.deleteNotification('n1'))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => NotificationsLoaded(notifications: tList, unreadCount: 1),
      act: (b) =>
          b.add(const DeleteNotificationRequested(notificationId: 'n1')),
      verify: (b) {
        expect((b.state as NotificationsLoaded).unreadCount, 0);
      },
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'does nothing when state is NOT NotificationsLoaded',
      build: () => bloc,
      seed: () => const NotificationsInitial(),
      act: (b) =>
          b.add(const DeleteNotificationRequested(notificationId: 'n1')),
      expect: () => <NotificationsState>[],
      verify: (_) => verifyNever(repository.deleteNotification(any)),
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'calls repository.deleteNotification with correct id',
      build: () {
        when(repository.deleteNotification('n1'))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => NotificationsLoaded(notifications: tList, unreadCount: 1),
      act: (b) =>
          b.add(const DeleteNotificationRequested(notificationId: 'n1')),
      verify: (_) => verify(repository.deleteNotification('n1')).called(1),
    );
  });

  // ═════════════════════════════════════════════════════════════
  // RefreshNotificationsRequested
  // ═════════════════════════════════════════════════════════════
  group('RefreshNotificationsRequested', () {
    blocTest<NotificationsBloc, NotificationsState>(
      'triggers full reload',
      build: () {
        when(repository.getNotifications())
            .thenAnswer((_) async => Right(tList));
        return bloc;
      },
      act: (b) => b.add(const RefreshNotificationsRequested()),
      expect: () => [
        const NotificationsLoading(),
        NotificationsLoaded(notifications: tList, unreadCount: 1),
      ],
      verify: (_) => verify(repository.getNotifications()).called(1),
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'recovers from error state after refresh',
      build: () {
        when(repository.getNotifications())
            .thenAnswer((_) async => Right(tList));
        return bloc;
      },
      seed: () => const NotificationsError(message: 'previous error'),
      act: (b) => b.add(const RefreshNotificationsRequested()),
      expect: () => [
        const NotificationsLoading(),
        NotificationsLoaded(notifications: tList, unreadCount: 1),
      ],
    );
  });

  // ═════════════════════════════════════════════════════════════
  // NewNotificationReceived — FCM foreground push
  // ═════════════════════════════════════════════════════════════
  group('NewNotificationReceived', () {
    group('FCM registration', () {
      blocTest<NotificationsBloc, NotificationsState>(
        'prepends new notification when state is Loaded',
        build: () => bloc,
        seed: () =>
            NotificationsLoaded(notifications: tList, unreadCount: 1),
        act: (b) => b.add(const NewNotificationReceived(data: {
          'type': 'new_offer',
          'title': 'New Offer',
          'message': 'Someone made an offer',
        })),
        verify: (b) {
          final s = b.state as NotificationsLoaded;
          expect(s.notifications.length, tList.length + 1);
          expect(s.notifications.first.title, 'New Offer');
          expect(s.notifications.first.isRead, isFalse);
          expect(s.notifications.first.type, NotificationType.newOffer);
        },
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'increments unreadCount when FCM message arrives',
        build: () => bloc,
        seed: () =>
            NotificationsLoaded(notifications: tList, unreadCount: 1),
        act: (b) => b.add(const NewNotificationReceived(data: {
          'type': 'general',
          'title': 'Hello',
          'message': 'World',
        })),
        verify: (b) {
          expect((b.state as NotificationsLoaded).unreadCount, 2);
        },
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'triggers LoadNotificationsRequested when state is NOT Loaded',
        build: () {
          when(repository.getNotifications())
              .thenAnswer((_) async => Right(tList));
          return bloc;
        },
        seed: () => const NotificationsInitial(),
        act: (b) => b.add(const NewNotificationReceived(data: {
          'type': 'general',
          'title': 'Hi',
          'message': 'There',
        })),
        expect: () => [
          const NotificationsLoading(),
          NotificationsLoaded(notifications: tList, unreadCount: 1),
        ],
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'uses default title when title missing from FCM data',
        build: () => bloc,
        seed: () =>
            NotificationsLoaded(notifications: const [], unreadCount: 0),
        act: (b) => b.add(const NewNotificationReceived(data: {})),
        verify: (b) {
          final s = b.state as NotificationsLoaded;
          expect(s.notifications.first.title, 'New Notification');
        },
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'correctly maps notification types from FCM data',
        build: () => bloc,
        seed: () =>
            NotificationsLoaded(notifications: const [], unreadCount: 0),
        act: (b) => b.add(const NewNotificationReceived(data: {
          'type': 'pickup_completed',
          'title': 'Pickup Done',
          'message': 'Your pickup is complete',
        })),
        verify: (b) {
          final s = b.state as NotificationsLoaded;
          expect(s.notifications.first.type, NotificationType.pickupCompleted);
        },
      );
    });
  });

  // ═════════════════════════════════════════════════════════════
  // RegisterFcmTokenRequested
  // ═════════════════════════════════════════════════════════════
  group('RegisterFcmTokenRequested', () {
    group('FCM registration', () {
      blocTest<NotificationsBloc, NotificationsState>(
        'calls repository.registerFcmToken with correct token',
        build: () {
          when(repository.registerFcmToken('test-token'))
              .thenAnswer((_) async => const Right(null));
          return bloc;
        },
        act: (b) => b.add(
            const RegisterFcmTokenRequested(token: 'test-token')),
        verify: (_) =>
            verify(repository.registerFcmToken('test-token')).called(1),
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'does NOT emit any new state (fire-and-forget)',
        build: () {
          when(repository.registerFcmToken(any))
              .thenAnswer((_) async => const Right(null));
          return bloc;
        },
        act: (b) =>
            b.add(const RegisterFcmTokenRequested(token: 'token-abc')),
        expect: () => <NotificationsState>[],
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'does NOT crash when registerFcmToken fails',
        build: () {
          when(repository.registerFcmToken(any)).thenThrow(Exception('FCM error'));
          return bloc;
        },
        act: (b) =>
            b.add(const RegisterFcmTokenRequested(token: 'bad-token')),
        expect: () => <NotificationsState>[],
        errors: () => <Matcher>[],
      );

      blocTest<NotificationsBloc, NotificationsState>(
        'does NOT crash when registerFcmToken returns Left failure',
        build: () {
          when(repository.registerFcmToken(any))
              .thenAnswer((_) async => const Left(tServerFailure));
          return bloc;
        },
        act: (b) =>
            b.add(const RegisterFcmTokenRequested(token: 'fail-token')),
        expect: () => <NotificationsState>[],
        errors: () => <Matcher>[],
      );
    });
  });

  // ═════════════════════════════════════════════════════════════
  // State equality
  // ═════════════════════════════════════════════════════════════
  group('State equality', () {
    test('NotificationsInitial equals NotificationsInitial', () {
      expect(const NotificationsInitial(), const NotificationsInitial());
    });

    test('NotificationsLoading equals NotificationsLoading', () {
      expect(const NotificationsLoading(), const NotificationsLoading());
    });

    test('NotificationsLoaded equals with same data', () {
      final a = NotificationsLoaded(notifications: tList, unreadCount: 1);
      final b = NotificationsLoaded(notifications: tList, unreadCount: 1);
      expect(a, equals(b));
    });

    test('NotificationsError equals with same message', () {
      expect(
        const NotificationsError(message: 'oops'),
        const NotificationsError(message: 'oops'),
      );
    });

    test('NotificationMarkedAsRead equals with same id', () {
      expect(
        const NotificationMarkedAsRead(notificationId: 'n1'),
        const NotificationMarkedAsRead(notificationId: 'n1'),
      );
    });

    test('AllNotificationsMarkedAsRead equals AllNotificationsMarkedAsRead', () {
      expect(
        const AllNotificationsMarkedAsRead(),
        const AllNotificationsMarkedAsRead(),
      );
    });

    test('NotificationDeleted equals with same id', () {
      expect(
        const NotificationDeleted(notificationId: 'n1'),
        const NotificationDeleted(notificationId: 'n1'),
      );
    });
  });
}
