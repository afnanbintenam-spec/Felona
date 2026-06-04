import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/errors/exceptions.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/eco_score/data/datasources/eco_remote_data_source.dart';
import 'package:felo_na/features/eco_score/data/models/eco_stats_model.dart';
import 'package:felo_na/features/eco_score/data/repositories/eco_repository_impl.dart';
import 'package:felo_na/features/eco_score/domain/entities/eco_stats.dart';

import 'eco_repository_impl_test.mocks.dart';

@GenerateMocks([EcoRemoteDataSource])
void main() {
  late MockEcoRemoteDataSource remoteDataSource;
  late EcoRepositoryImpl repository;

  // ─── fixtures ────────────────────────────────────────────────
  final tStatsModel = EcoStatsModel(
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

  final tHistoryModels = [
    PointHistoryModel(
      id: 'ph1',
      points: 25,
      reason: 'Completed pickup',
      date: DateTime.utc(2024, 4, 1),
    ),
  ];

  final tLeaderboard = [
    {'id': 'u1', 'name': 'Alice', 'eco_points': 1200},
    {'id': 'u2', 'name': 'Bob', 'eco_points': 980},
  ];

  setUp(() {
    remoteDataSource = MockEcoRemoteDataSource();
    repository = EcoRepositoryImpl(remoteDataSource: remoteDataSource);
  });

  // ═════════════════════════════════════════════════════════════
  // getEcoStats
  // ═════════════════════════════════════════════════════════════
  group('getEcoStats', () {
    group('stats loading success', () {
      test('returns Right(EcoStats) on success', () async {
        when(remoteDataSource.getEcoStats())
            .thenAnswer((_) async => tStatsModel);

        final result = await repository.getEcoStats();

        expect(result, isA<Right>());
        result.fold((_) => fail('Expected Right'), (stats) {
          expect(stats.totalPoints, 750);
          expect(stats.currentBadge, EcoBadgeType.silver);
        });
      });

      test('returned EcoStats is an EcoStats instance', () async {
        when(remoteDataSource.getEcoStats())
            .thenAnswer((_) async => tStatsModel);

        final result = await repository.getEcoStats();
        final stats = result.getOrElse(() => throw Exception('unexpected'));
        expect(stats, isA<EcoStats>());
      });
    });

    group('stats loading error handling', () {
      test('returns Left(ServerFailure) on ServerException', () async {
        when(remoteDataSource.getEcoStats())
            .thenThrow(const ServerException('Server error', 500));

        final result = await repository.getEcoStats();

        expect(result, isA<Left>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });

      test('returns Left(NetworkFailure) on NetworkException', () async {
        when(remoteDataSource.getEcoStats())
            .thenThrow(const NetworkException('No internet'));

        final result = await repository.getEcoStats();

        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Expected Left'),
        );
      });

      test('never throws — always returns Either', () async {
        when(remoteDataSource.getEcoStats())
            .thenThrow(Exception('unexpected'));

        expect(
          () async => repository.getEcoStats(),
          returnsNormally,
        );
      });
    });
  });

  // ═════════════════════════════════════════════════════════════
  // getPointHistory
  // ═════════════════════════════════════════════════════════════
  group('getPointHistory', () {
    group('point history success', () {
      test('returns Right(List<PointHistory>) on success', () async {
        when(remoteDataSource.getPointHistory(page: 1, limit: 20))
            .thenAnswer((_) async => tHistoryModels);

        final result =
            await repository.getPointHistory(page: 1, limit: 20);

        expect(result, isA<Right>());
        result.fold((_) => fail('Expected Right'), (history) {
          expect(history.length, 1);
          expect(history.first.points, 25);
        });
      });

      test('returns empty list when API returns empty', () async {
        when(remoteDataSource.getPointHistory(page: 1, limit: 20))
            .thenAnswer((_) async => []);

        final result =
            await repository.getPointHistory(page: 1, limit: 20);

        result.fold(
          (_) => fail('Expected Right'),
          (history) => expect(history, isEmpty),
        );
      });

      test('passes page and limit to data source', () async {
        when(remoteDataSource.getPointHistory(page: 2, limit: 10))
            .thenAnswer((_) async => []);

        await repository.getPointHistory(page: 2, limit: 10);

        verify(remoteDataSource.getPointHistory(page: 2, limit: 10))
            .called(1);
      });
    });

    group('point history empty response', () {
      test('empty response returns Right with empty list', () async {
        when(remoteDataSource.getPointHistory(
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        )).thenAnswer((_) async => []);

        final result = await repository.getPointHistory();

        result.fold(
          (_) => fail('Expected Right'),
          (list) => expect(list, isEmpty),
        );
      });
    });

    group('point history error handling', () {
      test('returns Left on ServerException', () async {
        when(remoteDataSource.getPointHistory(
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        )).thenThrow(const ServerException('Server error'));

        final result = await repository.getPointHistory();

        result.fold(
          (f) => expect(f, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });

      test('never throws — always returns Either', () async {
        when(remoteDataSource.getPointHistory(
          page: anyNamed('page'),
          limit: anyNamed('limit'),
        )).thenThrow(Exception('boom'));

        expect(
          () async => repository.getPointHistory(),
          returnsNormally,
        );
      });
    });
  });

  // ═════════════════════════════════════════════════════════════
  // addPoints
  // ═════════════════════════════════════════════════════════════
  group('addPoints', () {
    test('returns Right(EcoStats) on success', () async {
      when(remoteDataSource.addPoints(
        points: 50,
        reason: 'Pickup completed',
        relatedId: null,
      )).thenAnswer((_) async => tStatsModel);

      final result = await repository.addPoints(
        points: 50,
        reason: 'Pickup completed',
      );

      expect(result, isA<Right>());
      result.fold((_) => fail('Expected Right'), (s) {
        expect(s.totalPoints, 750);
      });
    });

    test('passes relatedId to data source', () async {
      when(remoteDataSource.addPoints(
        points: 25,
        reason: 'Sale',
        relatedId: 'listing-42',
      )).thenAnswer((_) async => tStatsModel);

      await repository.addPoints(
        points: 25,
        reason: 'Sale',
        relatedId: 'listing-42',
      );

      verify(remoteDataSource.addPoints(
        points: 25,
        reason: 'Sale',
        relatedId: 'listing-42',
      )).called(1);
    });

    group('error handling', () {
      test('returns Left(ServerFailure) on ServerException', () async {
        when(remoteDataSource.addPoints(
          points: anyNamed('points'),
          reason: anyNamed('reason'),
        )).thenThrow(const ServerException('Server error'));

        final result = await repository.addPoints(
          points: 50,
          reason: 'Pickup',
        );

        result.fold(
          (f) => expect(f, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });
    });
  });

  // ═════════════════════════════════════════════════════════════
  // getLeaderboard — leaderboard loading
  // ═════════════════════════════════════════════════════════════
  group('getLeaderboard', () {
    group('leaderboard loading success', () {
      test('returns Right(List<Map>) on success', () async {
        when(remoteDataSource.getLeaderboard(limit: 20))
            .thenAnswer((_) async => tLeaderboard);

        final result = await repository.getLeaderboard(limit: 20);

        expect(result, isA<Right>());
        result.fold((_) => fail('Expected Right'), (lb) {
          expect(lb.length, 2);
          expect(lb.first['name'], 'Alice');
        });
      });

      test('empty leaderboard returns Right with empty list', () async {
        when(remoteDataSource.getLeaderboard(limit: 20))
            .thenAnswer((_) async => []);

        final result = await repository.getLeaderboard(limit: 20);

        result.fold(
          (_) => fail('Expected Right'),
          (lb) => expect(lb, isEmpty),
        );
      });

      test('passes limit parameter to data source', () async {
        when(remoteDataSource.getLeaderboard(limit: 50))
            .thenAnswer((_) async => []);

        await repository.getLeaderboard(limit: 50);

        verify(remoteDataSource.getLeaderboard(limit: 50)).called(1);
      });
    });

    group('leaderboard error handling', () {
      test('returns Left(ServerFailure) on ServerException', () async {
        when(remoteDataSource.getLeaderboard(limit: 20))
            .thenThrow(const ServerException('Server error'));

        final result = await repository.getLeaderboard(limit: 20);

        result.fold(
          (f) => expect(f, isA<ServerFailure>()),
          (_) => fail('Expected Left'),
        );
      });

      test('returns Left(NetworkFailure) on NetworkException', () async {
        when(remoteDataSource.getLeaderboard(limit: 20))
            .thenThrow(const NetworkException('No internet'));

        final result = await repository.getLeaderboard(limit: 20);

        result.fold(
          (f) => expect(f, isA<NetworkFailure>()),
          (_) => fail('Expected Left'),
        );
      });

      test('never throws — always returns Either', () async {
        when(remoteDataSource.getLeaderboard(limit: 20))
            .thenThrow(Exception('unexpected'));

        expect(
          () async => repository.getLeaderboard(limit: 20),
          returnsNormally,
        );
      });
    });
  });
}
