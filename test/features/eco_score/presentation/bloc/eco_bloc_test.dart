import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/eco_score/domain/entities/eco_stats.dart';
import 'package:felo_na/features/eco_score/domain/repositories/eco_repository.dart';
import 'package:felo_na/features/eco_score/presentation/bloc/eco_bloc.dart';
import 'package:felo_na/features/eco_score/presentation/bloc/eco_event.dart';
import 'package:felo_na/features/eco_score/presentation/bloc/eco_state.dart';

import 'eco_bloc_test.mocks.dart';

@GenerateMocks([EcoRepository])
void main() {
  late MockEcoRepository repository;
  late EcoBloc bloc;

  // ─── shared fixtures ──────────────────────────────────────────
  final tStats = EcoStats(
    userId: 'u1',
    totalPoints: 750,
    totalWeightRecycled: 23.5,
    itemsSold: 5,
    pickupsCompleted: 8,
    co2Reduced: 12.3,
    currentBadge: EcoBadgeType.silver,
    currentStreak: 7,
    longestStreak: 14,
    lastActivityDate: DateTime.utc(2024, 4, 20),
    milestones: const [],
  );

  final tHistory = [
    PointHistory(
      id: 'ph1',
      points: 25,
      reason: 'Completed pickup',
      date: DateTime.utc(2024, 4, 1),
    ),
    PointHistory(
      id: 'ph2',
      points: 10,
      reason: 'Listed item',
      date: DateTime.utc(2024, 3, 28),
    ),
  ];

  const tServerFailure = ServerFailure('Server error');
  const tNetworkFailure = NetworkFailure('No internet');

  setUp(() {
    repository = MockEcoRepository();
    bloc = EcoBloc(repository: repository);
  });

  tearDown(() => bloc.close());

  // ─────────────────────────────────────────────────────────────
  // Initial state
  // ─────────────────────────────────────────────────────────────
  test('initial state is EcoInitial', () {
    expect(bloc.state, const EcoInitial());
  });

  // ═════════════════════════════════════════════════════════════
  // LoadEcoStatsRequested
  // ═════════════════════════════════════════════════════════════
  group('LoadEcoStatsRequested', () {
    group('stats loading', () {
      blocTest<EcoBloc, EcoState>(
        'emits [EcoLoading, EcoLoaded] when stats and history succeed',
        build: () {
          when(repository.getEcoStats()).thenAnswer((_) async => Right(tStats));
          when(repository.getPointHistory())
              .thenAnswer((_) async => Right(tHistory));
          return bloc;
        },
        act: (b) => b.add(const LoadEcoStatsRequested()),
        expect: () => [
          const EcoLoading(),
          EcoLoaded(stats: tStats, history: tHistory),
        ],
      );

      blocTest<EcoBloc, EcoState>(
        'emits [EcoLoading, EcoLoaded(history=[])] when history fails after stats succeed',
        build: () {
          when(repository.getEcoStats()).thenAnswer((_) async => Right(tStats));
          when(repository.getPointHistory())
              .thenAnswer((_) async => const Left(tServerFailure));
          return bloc;
        },
        act: (b) => b.add(const LoadEcoStatsRequested()),
        expect: () => [
          const EcoLoading(),
          EcoLoaded(stats: tStats, history: const []),
        ],
        verify: (_) {
          verify(repository.getEcoStats()).called(1);
          verify(repository.getPointHistory()).called(1);
        },
      );

      blocTest<EcoBloc, EcoState>(
        'emits [EcoLoading, EcoError] when stats fail',
        build: () {
          when(repository.getEcoStats())
              .thenAnswer((_) async => const Left(tServerFailure));
          // getPointHistory is always awaited even when stats fail
          when(repository.getPointHistory())
              .thenAnswer((_) async => const Right([]));
          return bloc;
        },
        act: (b) => b.add(const LoadEcoStatsRequested()),
        expect: () => [
          const EcoLoading(),
          const EcoError(message: 'Server error'),
        ],
        verify: (_) {
          verify(repository.getEcoStats()).called(1);
          verify(repository.getPointHistory()).called(1);
        },
      );

      blocTest<EcoBloc, EcoState>(
        'emits [EcoLoading, EcoError] on network failure',
        build: () {
          when(repository.getEcoStats())
              .thenAnswer((_) async => const Left(tNetworkFailure));
          when(repository.getPointHistory())
              .thenAnswer((_) async => const Right([]));
          return bloc;
        },
        act: (b) => b.add(const LoadEcoStatsRequested()),
        expect: () => [
          const EcoLoading(),
          const EcoError(message: 'No internet'),
        ],
      );

      blocTest<EcoBloc, EcoState>(
        'loaded state contains correct stats values',
        build: () {
          when(repository.getEcoStats()).thenAnswer((_) async => Right(tStats));
          when(repository.getPointHistory())
              .thenAnswer((_) async => Right(tHistory));
          return bloc;
        },
        act: (b) => b.add(const LoadEcoStatsRequested()),
        verify: (b) {
          final loaded = b.state as EcoLoaded;
          expect(loaded.stats.totalPoints, 750);
          expect(loaded.stats.currentBadge, EcoBadgeType.silver);
          expect(loaded.history.length, 2);
        },
      );
    });

    // ─── point history empty response ─────────────────────────
    group('point history empty response', () {
      blocTest<EcoBloc, EcoState>(
        'emits EcoLoaded with empty history when API returns []',
        build: () {
          when(repository.getEcoStats()).thenAnswer((_) async => Right(tStats));
          when(repository.getPointHistory())
              .thenAnswer((_) async => const Right([]));
          return bloc;
        },
        act: (b) => b.add(const LoadEcoStatsRequested()),
        expect: () => [
          const EcoLoading(),
          EcoLoaded(stats: tStats, history: const []),
        ],
      );

      blocTest<EcoBloc, EcoState>(
        'empty history does not block stats from loading',
        build: () {
          when(repository.getEcoStats()).thenAnswer((_) async => Right(tStats));
          when(repository.getPointHistory())
              .thenAnswer((_) async => const Right([]));
          return bloc;
        },
        act: (b) => b.add(const LoadEcoStatsRequested()),
        verify: (b) {
          final state = b.state as EcoLoaded;
          expect(state.history, isEmpty);
          expect(state.stats.userId, 'u1');
        },
      );
    });

    // ─── error handling ───────────────────────────────────────
    group('error handling', () {
      blocTest<EcoBloc, EcoState>(
        'error message is propagated from ServerFailure',
        build: () {
          when(repository.getEcoStats()).thenAnswer(
            (_) async => const Left(ServerFailure('Internal server error', 500)),
          );
          when(repository.getPointHistory())
              .thenAnswer((_) async => const Right([]));
          return bloc;
        },
        act: (b) => b.add(const LoadEcoStatsRequested()),
        expect: () => [
          const EcoLoading(),
          const EcoError(message: 'Internal server error'),
        ],
      );

      blocTest<EcoBloc, EcoState>(
        'error message is propagated from NetworkFailure',
        build: () {
          when(repository.getEcoStats()).thenAnswer(
            (_) async => const Left(NetworkFailure('Connection timed out')),
          );
          when(repository.getPointHistory())
              .thenAnswer((_) async => const Right([]));
          return bloc;
        },
        act: (b) => b.add(const LoadEcoStatsRequested()),
        expect: () => [
          const EcoLoading(),
          const EcoError(message: 'Connection timed out'),
        ],
      );

      blocTest<EcoBloc, EcoState>(
        'always emits EcoLoading before error',
        build: () {
          when(repository.getEcoStats())
              .thenAnswer((_) async => const Left(tServerFailure));
          when(repository.getPointHistory())
              .thenAnswer((_) async => const Right([]));
          return bloc;
        },
        act: (b) => b.add(const LoadEcoStatsRequested()),
        expect: () => [isA<EcoLoading>(), isA<EcoError>()],
      );
    });
  });

  // ═════════════════════════════════════════════════════════════
  // LoadPointHistoryRequested
  // ═════════════════════════════════════════════════════════════
  group('LoadPointHistoryRequested', () {
    group('leaderboard loading (history reload)', () {
      blocTest<EcoBloc, EcoState>(
        'updates history when state is EcoLoaded',
        build: () {
          when(repository.getEcoStats()).thenAnswer((_) async => Right(tStats));
          when(repository.getPointHistory())
              .thenAnswer((_) async => Right(tHistory));
          return bloc;
        },
        seed: () => EcoLoaded(stats: tStats, history: const []),
        act: (b) => b.add(const LoadPointHistoryRequested()),
        expect: () => [
          const EcoLoading(),
          EcoLoaded(stats: tStats, history: tHistory),
        ],
      );

      blocTest<EcoBloc, EcoState>(
        'does nothing when state is NOT EcoLoaded',
        build: () => bloc,
        seed: () => const EcoInitial(),
        act: (b) => b.add(const LoadPointHistoryRequested()),
        expect: () => <EcoState>[],
        verify: (_) => verifyNever(repository.getPointHistory()),
      );

      blocTest<EcoBloc, EcoState>(
        'does nothing when state is EcoLoading',
        build: () => bloc,
        seed: () => const EcoLoading(),
        act: (b) => b.add(const LoadPointHistoryRequested()),
        expect: () => <EcoState>[],
      );

      blocTest<EcoBloc, EcoState>(
        'emits EcoError when history reload fails',
        build: () {
          when(repository.getPointHistory())
              .thenAnswer((_) async => const Left(tServerFailure));
          return bloc;
        },
        seed: () => EcoLoaded(stats: tStats, history: const []),
        act: (b) => b.add(const LoadPointHistoryRequested()),
        expect: () => [
          const EcoLoading(),
          const EcoError(message: 'Server error'),
        ],
      );

      blocTest<EcoBloc, EcoState>(
        'empty history response clears existing history entries',
        build: () {
          when(repository.getPointHistory())
              .thenAnswer((_) async => const Right([]));
          return bloc;
        },
        seed: () => EcoLoaded(stats: tStats, history: tHistory),
        act: (b) => b.add(const LoadPointHistoryRequested()),
        expect: () => [
          const EcoLoading(),
          EcoLoaded(stats: tStats, history: const []),
        ],
      );
    });
  });

  // ═════════════════════════════════════════════════════════════
  // AddPointsRequested
  // ═════════════════════════════════════════════════════════════
  group('AddPointsRequested', () {
    final tUpdatedStats = tStats.copyWith(totalPoints: 800);

    group('success', () {
      blocTest<EcoBloc, EcoState>(
        'emits PointsAdded then reloads stats on success',
        build: () {
          when(repository.addPoints(points: 50, reason: 'Pickup completed'))
              .thenAnswer((_) async => Right(tUpdatedStats));
          when(repository.getEcoStats())
              .thenAnswer((_) async => Right(tUpdatedStats));
          when(repository.getPointHistory())
              .thenAnswer((_) async => Right(tHistory));
          return bloc;
        },
        seed: () => EcoLoaded(stats: tStats, history: tHistory),
        act: (b) => b.add(
          const AddPointsRequested(points: 50, reason: 'Pickup completed'),
        ),
        expect: () => [
          const PointsAdded(points: 50),
          const EcoLoading(),
          EcoLoaded(stats: tUpdatedStats, history: tHistory),
        ],
      );

      blocTest<EcoBloc, EcoState>(
        'PointsAdded carries correct point value',
        build: () {
          when(repository.addPoints(points: 100, reason: 'Milestone'))
              .thenAnswer((_) async => Right(tUpdatedStats));
          when(repository.getEcoStats())
              .thenAnswer((_) async => Right(tUpdatedStats));
          when(repository.getPointHistory())
              .thenAnswer((_) async => const Right([]));
          return bloc;
        },
        seed: () => EcoLoaded(stats: tStats, history: const []),
        act: (b) => b.add(
          const AddPointsRequested(points: 100, reason: 'Milestone'),
        ),
        verify: (b) {
          // First emitted state (after seed) is PointsAdded
          // Can't easily inspect intermediate states here, verified via expect above
        },
        expect: () => [
          const PointsAdded(points: 100),
          const EcoLoading(),
          EcoLoaded(stats: tUpdatedStats, history: const []),
        ],
      );
    });

    group('error handling', () {
      blocTest<EcoBloc, EcoState>(
        'emits EcoError when addPoints fails',
        build: () {
          when(repository.addPoints(
            points: anyNamed('points'),
            reason: anyNamed('reason'),
          )).thenAnswer((_) async => const Left(tServerFailure));
          return bloc;
        },
        seed: () => EcoLoaded(stats: tStats, history: tHistory),
        act: (b) => b.add(
          const AddPointsRequested(points: 50, reason: 'Pickup'),
        ),
        expect: () => [const EcoError(message: 'Server error')],
      );

      blocTest<EcoBloc, EcoState>(
        'does nothing when state is NOT EcoLoaded',
        build: () => bloc,
        seed: () => const EcoInitial(),
        act: (b) => b.add(
          const AddPointsRequested(points: 50, reason: 'Pickup'),
        ),
        expect: () => <EcoState>[],
        verify: (_) => verifyNever(repository.addPoints(
          points: anyNamed('points'),
          reason: anyNamed('reason'),
        )),
      );

      blocTest<EcoBloc, EcoState>(
        'does nothing when state is EcoError',
        build: () => bloc,
        seed: () => const EcoError(message: 'previous error'),
        act: (b) => b.add(
          const AddPointsRequested(points: 50, reason: 'Pickup'),
        ),
        expect: () => <EcoState>[],
      );
    });
  });

  // ═════════════════════════════════════════════════════════════
  // RefreshEcoStatsRequested
  // ═════════════════════════════════════════════════════════════
  group('RefreshEcoStatsRequested', () {
    blocTest<EcoBloc, EcoState>(
      'triggers full stats reload',
      build: () {
        when(repository.getEcoStats()).thenAnswer((_) async => Right(tStats));
        when(repository.getPointHistory())
            .thenAnswer((_) async => Right(tHistory));
        return bloc;
      },
      act: (b) => b.add(const RefreshEcoStatsRequested()),
      expect: () => [
        const EcoLoading(),
        EcoLoaded(stats: tStats, history: tHistory),
      ],
      verify: (_) {
        verify(repository.getEcoStats()).called(1);
        verify(repository.getPointHistory()).called(1);
      },
    );

    blocTest<EcoBloc, EcoState>(
      'refresh after error recovers to EcoLoaded',
      build: () {
        when(repository.getEcoStats()).thenAnswer((_) async => Right(tStats));
        when(repository.getPointHistory())
            .thenAnswer((_) async => const Right([]));
        return bloc;
      },
      seed: () => const EcoError(message: 'previous error'),
      act: (b) => b.add(const RefreshEcoStatsRequested()),
      expect: () => [
        const EcoLoading(),
        EcoLoaded(stats: tStats, history: const []),
      ],
    );
  });

  // ═════════════════════════════════════════════════════════════
  // State equality
  // ═════════════════════════════════════════════════════════════
  group('State equality', () {
    test('EcoInitial equals EcoInitial', () {
      expect(const EcoInitial(), const EcoInitial());
    });

    test('EcoLoading equals EcoLoading', () {
      expect(const EcoLoading(), const EcoLoading());
    });

    test('EcoLoaded equals when same stats and history', () {
      final a = EcoLoaded(stats: tStats, history: tHistory);
      final b = EcoLoaded(stats: tStats, history: tHistory);
      expect(a, equals(b));
    });

    test('EcoError equals when same message', () {
      expect(
        const EcoError(message: 'oops'),
        const EcoError(message: 'oops'),
      );
    });

    test('EcoError not equal with different messages', () {
      expect(
        const EcoError(message: 'a'),
        isNot(equals(const EcoError(message: 'b'))),
      );
    });

    test('PointsAdded equals when same points', () {
      expect(const PointsAdded(points: 50), const PointsAdded(points: 50));
    });
  });

  // ═════════════════════════════════════════════════════════════
  // Repository call counts
  // ═════════════════════════════════════════════════════════════
  group('Repository interaction verification', () {
    blocTest<EcoBloc, EcoState>(
      'LoadEcoStatsRequested calls both getEcoStats and getPointHistory',
      build: () {
        when(repository.getEcoStats()).thenAnswer((_) async => Right(tStats));
        when(repository.getPointHistory())
            .thenAnswer((_) async => Right(tHistory));
        return bloc;
      },
      act: (b) => b.add(const LoadEcoStatsRequested()),
      verify: (_) {
        verify(repository.getEcoStats()).called(1);
        verify(repository.getPointHistory()).called(1);
      },
    );

    blocTest<EcoBloc, EcoState>(
      'getPointHistory IS also called even when getEcoStats fails',
      build: () {
        when(repository.getEcoStats())
            .thenAnswer((_) async => const Left(tServerFailure));
        when(repository.getPointHistory())
            .thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (b) => b.add(const LoadEcoStatsRequested()),
      verify: (_) {
        verify(repository.getEcoStats()).called(1);
        verify(repository.getPointHistory()).called(1);
      },
    );
  });
}
