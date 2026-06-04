import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/pickup/domain/entities/pickup_request.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_bloc.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_event.dart';
import 'package:felo_na/features/pickup/presentation/bloc/pickup_state.dart';

// Reuse the MockPickupRepository already generated for the use-case tests.
import '../../domain/usecases/pickup_usecases_test.mocks.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared fixtures
// ─────────────────────────────────────────────────────────────────────────────

final _tCreatedAt = DateTime(2025, 1, 15);
final _tScheduledDate = DateTime(2025, 1, 20);

PickupRequest _makePickup({
  String id = 'pickup-1',
  PickupStatus status = PickupStatus.pending,
  bool isRecurring = false,
  String? recurringScheduleId,
  String? qrToken,
  double? rating,
  String? feedback,
  int? ecoPointsEarned,
  double? collectorLatitude,
  double? collectorLongitude,
  int? etaMinutes,
}) =>
    PickupRequest(
      id: id,
      userId: 'user-1',
      userName: 'Hana',
      category: WasteCategory.plastic,
      estimatedWeight: 3.5,
      address: '12 Green St, Addis Ababa',
      status: status,
      createdAt: _tCreatedAt,
      isRecurring: isRecurring,
      recurringScheduleId: recurringScheduleId,
      qrToken: qrToken,
      rating: rating,
      feedback: feedback,
      ecoPointsEarned: ecoPointsEarned,
      collectorLatitude: collectorLatitude,
      collectorLongitude: collectorLongitude,
      etaMinutes: etaMinutes,
    );

const _tNetworkFailure = NetworkFailure('No internet connection', 'NO_CONNECTION');
const _tServerFailure = ServerFailure('Internal server error', 500, 'SERVER_ERROR');
const _tAuthFailure = AuthorizationFailure('Not authorised', 'FORBIDDEN');

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late MockPickupRepository mockRepo;

  setUp(() => mockRepo = MockPickupRepository());

  PickupBloc _bloc() => PickupBloc(repository: mockRepo);

  // ══════════════════════════════════════════════════════════════════════════
  // Initial state
  // ══════════════════════════════════════════════════════════════════════════
  group('PickupBloc — initial state', () {
    test('initial state is PickupInitial', () {
      expect(_bloc().state, const PickupInitial());
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // LoadPickupsRequested
  // ══════════════════════════════════════════════════════════════════════════
  group('LoadPickupsRequested', () {
    final tPickups = [
      _makePickup(id: 'p-1'),
      _makePickup(id: 'p-2', status: PickupStatus.accepted),
    ];

    blocTest<PickupBloc, PickupState>(
      'emits [PickupLoading, PickupLoaded] when repository returns list',
      build: _bloc,
      setUp: () {
        when(mockRepo.getPickups())
            .thenAnswer((_) async => Right(tPickups));
      },
      act: (bloc) => bloc.add(const LoadPickupsRequested()),
      expect: () => [
        const PickupLoading(),
        PickupLoaded(pickups: tPickups),
      ],
      verify: (_) => verify(mockRepo.getPickups()).called(1),
    );

    blocTest<PickupBloc, PickupState>(
      'emits [PickupLoading, PickupLoaded] with empty list',
      build: _bloc,
      setUp: () {
        when(mockRepo.getPickups())
            .thenAnswer((_) async => const Right([]));
      },
      act: (bloc) => bloc.add(const LoadPickupsRequested()),
      expect: () => [
        const PickupLoading(),
        const PickupLoaded(pickups: []),
      ],
    );

    blocTest<PickupBloc, PickupState>(
      'emits [PickupLoading, PickupError] on NetworkFailure',
      build: _bloc,
      setUp: () {
        when(mockRepo.getPickups())
            .thenAnswer((_) async => const Left(_tNetworkFailure));
      },
      act: (bloc) => bloc.add(const LoadPickupsRequested()),
      expect: () => [
        const PickupLoading(),
        const PickupError(message: 'No internet connection'),
      ],
    );

    blocTest<PickupBloc, PickupState>(
      'emits [PickupLoading, PickupError] on ServerFailure',
      build: _bloc,
      setUp: () {
        when(mockRepo.getPickups())
            .thenAnswer((_) async => const Left(_tServerFailure));
      },
      act: (bloc) => bloc.add(const LoadPickupsRequested()),
      expect: () => [
        const PickupLoading(),
        const PickupError(message: 'Internal server error'),
      ],
    );

    blocTest<PickupBloc, PickupState>(
      'preserves exact failure message in PickupError',
      build: _bloc,
      setUp: () {
        when(mockRepo.getPickups()).thenAnswer(
          (_) async => const Left(ServerFailure('Custom error msg')),
        );
      },
      act: (bloc) => bloc.add(const LoadPickupsRequested()),
      expect: () => [
        const PickupLoading(),
        const PickupError(message: 'Custom error msg'),
      ],
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // CreatePickupRequested
  // ══════════════════════════════════════════════════════════════════════════
  group('CreatePickupRequested', () {
    final tPickup = _makePickup(id: 'new-1');

    const tEvent = CreatePickupRequested(
      category: WasteCategory.plastic,
      estimatedWeight: 3.5,
      address: '12 Green St, Addis Ababa',
    );

    blocTest<PickupBloc, PickupState>(
      'emits [CreatingPickup, PickupCreated] on success',
      build: _bloc,
      setUp: () {
        when(mockRepo.createPickup(
          category: WasteCategory.plastic,
          estimatedWeight: 3.5,
          address: '12 Green St, Addis Ababa',
          latitude: null,
          longitude: null,
          notes: null,
          scheduledDate: null,
          timeSlot: null,
          isRecurring: false,
          recurrenceFrequency: null,
          recurrenceDayOfWeek: null,
        )).thenAnswer((_) async => Right(tPickup));
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        const CreatingPickup(),
        PickupCreated(pickup: tPickup),
      ],
      verify: (_) => verify(mockRepo.createPickup(
        category: WasteCategory.plastic,
        estimatedWeight: 3.5,
        address: '12 Green St, Addis Ababa',
        latitude: null,
        longitude: null,
        notes: null,
        scheduledDate: null,
        timeSlot: null,
        isRecurring: false,
        recurrenceFrequency: null,
        recurrenceDayOfWeek: null,
      )).called(1),
    );

    blocTest<PickupBloc, PickupState>(
      'emits [CreatingPickup, PickupError] on failure',
      build: _bloc,
      setUp: () {
        when(mockRepo.createPickup(
          category: anyNamed('category'),
          estimatedWeight: anyNamed('estimatedWeight'),
          address: anyNamed('address'),
          latitude: anyNamed('latitude'),
          longitude: anyNamed('longitude'),
          notes: anyNamed('notes'),
          scheduledDate: anyNamed('scheduledDate'),
          timeSlot: anyNamed('timeSlot'),
          isRecurring: anyNamed('isRecurring'),
          recurrenceFrequency: anyNamed('recurrenceFrequency'),
          recurrenceDayOfWeek: anyNamed('recurrenceDayOfWeek'),
        )).thenAnswer((_) async => const Left(_tNetworkFailure));
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        const CreatingPickup(),
        const PickupError(message: 'No internet connection'),
      ],
    );

    blocTest<PickupBloc, PickupState>(
      'passes all scheduling fields to repository',
      build: _bloc,
      setUp: () {
        when(mockRepo.createPickup(
          category: WasteCategory.metal,
          estimatedWeight: 5.0,
          address: 'Test Rd',
          latitude: 9.02,
          longitude: 38.74,
          notes: 'Be careful',
          scheduledDate: _tScheduledDate,
          timeSlot: PickupTimeSlot.morning1,
          isRecurring: false,
          recurrenceFrequency: null,
          recurrenceDayOfWeek: null,
        )).thenAnswer(
          (_) async => Right(_makePickup(id: 'sched-1')),
        );
      },
      act: (bloc) => bloc.add(CreatePickupRequested(
        category: WasteCategory.metal,
        estimatedWeight: 5.0,
        address: 'Test Rd',
        latitude: 9.02,
        longitude: 38.74,
        notes: 'Be careful',
        scheduledDate: _tScheduledDate,
        timeSlot: PickupTimeSlot.morning1,
      )),
      expect: () => [
        const CreatingPickup(),
        PickupCreated(pickup: _makePickup(id: 'sched-1')),
      ],
    );

    blocTest<PickupBloc, PickupState>(
      'passes recurring fields to repository',
      build: _bloc,
      setUp: () {
        when(mockRepo.createPickup(
          category: WasteCategory.paper,
          estimatedWeight: 2.0,
          address: 'Recurring Rd',
          latitude: null,
          longitude: null,
          notes: null,
          scheduledDate: null,
          timeSlot: null,
          isRecurring: true,
          recurrenceFrequency: RecurrenceFrequency.weekly,
          recurrenceDayOfWeek: 3,
        )).thenAnswer(
          (_) async => Right(_makePickup(id: 'rec-1', isRecurring: true)),
        );
      },
      act: (bloc) => bloc.add(const CreatePickupRequested(
        category: WasteCategory.paper,
        estimatedWeight: 2.0,
        address: 'Recurring Rd',
        isRecurring: true,
        recurrenceFrequency: RecurrenceFrequency.weekly,
        recurrenceDayOfWeek: 3,
      )),
      expect: () => [
        const CreatingPickup(),
        PickupCreated(pickup: _makePickup(id: 'rec-1', isRecurring: true)),
      ],
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // LoadPickupDetailRequested
  // ══════════════════════════════════════════════════════════════════════════
  group('LoadPickupDetailRequested', () {
    final tPickup = _makePickup(id: 'detail-1', status: PickupStatus.accepted);

    blocTest<PickupBloc, PickupState>(
      'emits [PickupLoading, PickupDetailLoaded] on success',
      build: _bloc,
      setUp: () {
        when(mockRepo.getPickupById('detail-1'))
            .thenAnswer((_) async => Right(tPickup));
      },
      act: (bloc) =>
          bloc.add(const LoadPickupDetailRequested(pickupId: 'detail-1')),
      expect: () => [
        const PickupLoading(),
        PickupDetailLoaded(pickup: tPickup),
      ],
      verify: (_) =>
          verify(mockRepo.getPickupById('detail-1')).called(1),
    );

    blocTest<PickupBloc, PickupState>(
      'emits [PickupLoading, PickupError] on failure',
      build: _bloc,
      setUp: () {
        when(mockRepo.getPickupById('bad-id'))
            .thenAnswer((_) async =>
                const Left(ServerFailure('Not found', 404, 'NOT_FOUND')));
      },
      act: (bloc) =>
          bloc.add(const LoadPickupDetailRequested(pickupId: 'bad-id')),
      expect: () => [
        const PickupLoading(),
        const PickupError(message: 'Not found'),
      ],
    );

    blocTest<PickupBloc, PickupState>(
      'detail load passes the correct pickupId',
      build: _bloc,
      setUp: () {
        when(mockRepo.getPickupById('specific-id')).thenAnswer(
          (_) async => Right(_makePickup(id: 'specific-id')),
        );
      },
      act: (bloc) =>
          bloc.add(const LoadPickupDetailRequested(pickupId: 'specific-id')),
      verify: (_) =>
          verify(mockRepo.getPickupById('specific-id')).called(1),
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // AcceptPickupRequested (acceptance flow)
  // ══════════════════════════════════════════════════════════════════════════
  group('AcceptPickupRequested', () {
    final tAccepted =
        _makePickup(id: 'p-1', status: PickupStatus.accepted);

    blocTest<PickupBloc, PickupState>(
      'emits [PickupLoading, PickupStatusUpdated] on success',
      build: _bloc,
      setUp: () {
        when(mockRepo.acceptPickup('p-1'))
            .thenAnswer((_) async => Right(tAccepted));
      },
      act: (bloc) =>
          bloc.add(const AcceptPickupRequested(pickupId: 'p-1')),
      expect: () => [
        const PickupLoading(),
        PickupStatusUpdated(pickup: tAccepted),
      ],
      verify: (_) =>
          verify(mockRepo.acceptPickup('p-1')).called(1),
    );

    blocTest<PickupBloc, PickupState>(
      'emits [PickupLoading, PickupError] on AuthorizationFailure',
      build: _bloc,
      setUp: () {
        when(mockRepo.acceptPickup('p-1'))
            .thenAnswer((_) async => const Left(_tAuthFailure));
      },
      act: (bloc) =>
          bloc.add(const AcceptPickupRequested(pickupId: 'p-1')),
      expect: () => [
        const PickupLoading(),
        const PickupError(message: 'Not authorised'),
      ],
    );

    blocTest<PickupBloc, PickupState>(
      'accepted pickup has status = accepted in the emitted state',
      build: _bloc,
      setUp: () {
        when(mockRepo.acceptPickup('p-1'))
            .thenAnswer((_) async => Right(tAccepted));
      },
      act: (bloc) =>
          bloc.add(const AcceptPickupRequested(pickupId: 'p-1')),
      expect: () => [
        const PickupLoading(),
        predicate<PickupState>((s) =>
            s is PickupStatusUpdated &&
            s.pickup.status == PickupStatus.accepted),
      ],
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // UpdatePickupStatusRequested (status updates)
  // ══════════════════════════════════════════════════════════════════════════
  group('UpdatePickupStatusRequested', () {
    for (final newStatus in [
      PickupStatus.onTheWay,
      PickupStatus.arrived,
      PickupStatus.completed,
      PickupStatus.cancelled,
    ]) {
      blocTest<PickupBloc, PickupState>(
        'emits [PickupLoading, PickupStatusUpdated] for status → $newStatus',
        build: _bloc,
        setUp: () {
          when(mockRepo.updatePickupStatus('p-1', newStatus)).thenAnswer(
            (_) async =>
                Right(_makePickup(id: 'p-1', status: newStatus)),
          );
        },
        act: (bloc) => bloc.add(UpdatePickupStatusRequested(
          pickupId: 'p-1',
          newStatus: newStatus,
        )),
        expect: () => [
          const PickupLoading(),
          PickupStatusUpdated(
              pickup: _makePickup(id: 'p-1', status: newStatus)),
        ],
        verify: (_) =>
            verify(mockRepo.updatePickupStatus('p-1', newStatus)).called(1),
      );
    }

    blocTest<PickupBloc, PickupState>(
      'emits [PickupLoading, PickupError] on failure',
      build: _bloc,
      setUp: () {
        when(mockRepo.updatePickupStatus(any, any))
            .thenAnswer((_) async => const Left(_tServerFailure));
      },
      act: (bloc) => bloc.add(const UpdatePickupStatusRequested(
        pickupId: 'p-1',
        newStatus: PickupStatus.onTheWay,
      )),
      expect: () => [
        const PickupLoading(),
        const PickupError(message: 'Internal server error'),
      ],
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // CompletePickupRequested (completion flow)
  // ══════════════════════════════════════════════════════════════════════════
  group('CompletePickupRequested', () {
    final tCompleted = _makePickup(
      id: 'p-1',
      status: PickupStatus.completed,
      ecoPointsEarned: 30,
    );

    blocTest<PickupBloc, PickupState>(
      'emits [PickupLoading, PickupStatusUpdated] on success',
      build: _bloc,
      setUp: () {
        when(mockRepo.completePickup('p-1'))
            .thenAnswer((_) async => Right(tCompleted));
      },
      act: (bloc) =>
          bloc.add(const CompletePickupRequested(pickupId: 'p-1')),
      expect: () => [
        const PickupLoading(),
        PickupStatusUpdated(pickup: tCompleted),
      ],
      verify: (_) =>
          verify(mockRepo.completePickup('p-1')).called(1),
    );

    blocTest<PickupBloc, PickupState>(
      'completed pickup has status = completed in the state',
      build: _bloc,
      setUp: () {
        when(mockRepo.completePickup('p-1'))
            .thenAnswer((_) async => Right(tCompleted));
      },
      act: (bloc) =>
          bloc.add(const CompletePickupRequested(pickupId: 'p-1')),
      expect: () => [
        const PickupLoading(),
        predicate<PickupState>((s) =>
            s is PickupStatusUpdated &&
            s.pickup.status == PickupStatus.completed),
      ],
    );

    blocTest<PickupBloc, PickupState>(
      'emits [PickupLoading, PickupError] on failure',
      build: _bloc,
      setUp: () {
        when(mockRepo.completePickup('p-1'))
            .thenAnswer((_) async => const Left(_tServerFailure));
      },
      act: (bloc) =>
          bloc.add(const CompletePickupRequested(pickupId: 'p-1')),
      expect: () => [
        const PickupLoading(),
        const PickupError(message: 'Internal server error'),
      ],
    );

    blocTest<PickupBloc, PickupState>(
      'eco points are reflected in completed pickup state',
      build: _bloc,
      setUp: () {
        when(mockRepo.completePickup('p-1'))
            .thenAnswer((_) async => Right(tCompleted));
      },
      act: (bloc) =>
          bloc.add(const CompletePickupRequested(pickupId: 'p-1')),
      expect: () => [
        const PickupLoading(),
        predicate<PickupState>((s) =>
            s is PickupStatusUpdated && s.pickup.ecoPointsEarned == 30),
      ],
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // LoadPickupHistoryRequested (pagination)
  // ══════════════════════════════════════════════════════════════════════════
  group('LoadPickupHistoryRequested — pagination', () {
    final tPage1 = List.generate(
        20, (i) => _makePickup(id: 'h-${i + 1}', status: PickupStatus.completed));
    final tPage2 = List.generate(
        10, (i) => _makePickup(id: 'h-${21 + i}', status: PickupStatus.completed));

    blocTest<PickupBloc, PickupState>(
      'emits [PickupLoading, PickupHistoryLoaded] with page=1 defaults',
      build: _bloc,
      setUp: () {
        when(mockRepo.getMyPickupHistory(page: 1, limit: 20))
            .thenAnswer((_) async => Right(tPage1));
      },
      act: (bloc) => bloc.add(const LoadPickupHistoryRequested()),
      expect: () => [
        const PickupLoading(),
        PickupHistoryLoaded(
          pickups: tPage1,
          currentPage: 1,
          hasMore: true,
        ),
      ],
      verify: (_) =>
          verify(mockRepo.getMyPickupHistory(page: 1, limit: 20)).called(1),
    );

    blocTest<PickupBloc, PickupState>(
      'passes custom page=2, limit=10 to repository',
      build: _bloc,
      setUp: () {
        when(mockRepo.getMyPickupHistory(page: 2, limit: 10))
            .thenAnswer((_) async => Right(tPage2));
      },
      act: (bloc) =>
          bloc.add(const LoadPickupHistoryRequested(page: 2, limit: 10)),
      expect: () => [
        const PickupLoading(),
        PickupHistoryLoaded(
          pickups: tPage2,
          currentPage: 2,
          hasMore: true, // 10 >= 10
        ),
      ],
      verify: (_) =>
          verify(mockRepo.getMyPickupHistory(page: 2, limit: 10)).called(1),
    );

    blocTest<PickupBloc, PickupState>(
      'hasMore is true when pickups.length == limit',
      build: _bloc,
      setUp: () {
        when(mockRepo.getMyPickupHistory(page: 1, limit: 5))
            .thenAnswer((_) async =>
                Right(List.generate(5, (i) => _makePickup(id: 'x-$i'))));
      },
      act: (bloc) =>
          bloc.add(const LoadPickupHistoryRequested(page: 1, limit: 5)),
      expect: () => [
        const PickupLoading(),
        predicate<PickupState>(
            (s) => s is PickupHistoryLoaded && s.hasMore == true),
      ],
    );

    blocTest<PickupBloc, PickupState>(
      'hasMore is false when pickups.length < limit',
      build: _bloc,
      setUp: () {
        when(mockRepo.getMyPickupHistory(page: 3, limit: 20))
            .thenAnswer((_) async =>
                Right(List.generate(7, (i) => _makePickup(id: 'y-$i'))));
      },
      act: (bloc) =>
          bloc.add(const LoadPickupHistoryRequested(page: 3, limit: 20)),
      expect: () => [
        const PickupLoading(),
        predicate<PickupState>(
            (s) => s is PickupHistoryLoaded && s.hasMore == false),
      ],
    );

    blocTest<PickupBloc, PickupState>(
      'hasMore is false for empty result',
      build: _bloc,
      setUp: () {
        when(mockRepo.getMyPickupHistory(page: 99, limit: 20))
            .thenAnswer((_) async => const Right([]));
      },
      act: (bloc) =>
          bloc.add(const LoadPickupHistoryRequested(page: 99, limit: 20)),
      expect: () => [
        const PickupLoading(),
        const PickupHistoryLoaded(
          pickups: [],
          currentPage: 99,
          hasMore: false,
        ),
      ],
    );

    blocTest<PickupBloc, PickupState>(
      'currentPage reflects the requested page in state',
      build: _bloc,
      setUp: () {
        when(mockRepo.getMyPickupHistory(page: 5, limit: 20))
            .thenAnswer((_) async =>
                Right(List.generate(3, (i) => _makePickup(id: 'z-$i'))));
      },
      act: (bloc) =>
          bloc.add(const LoadPickupHistoryRequested(page: 5, limit: 20)),
      expect: () => [
        const PickupLoading(),
        predicate<PickupState>(
            (s) => s is PickupHistoryLoaded && s.currentPage == 5),
      ],
    );

    blocTest<PickupBloc, PickupState>(
      'emits [PickupLoading, PickupError] on failure',
      build: _bloc,
      setUp: () {
        when(mockRepo.getMyPickupHistory(page: 1, limit: 20))
            .thenAnswer((_) async => const Left(_tNetworkFailure));
      },
      act: (bloc) => bloc.add(const LoadPickupHistoryRequested()),
      expect: () => [
        const PickupLoading(),
        const PickupError(message: 'No internet connection'),
      ],
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // RatePickupRequested (ratings)
  // ══════════════════════════════════════════════════════════════════════════
  group('RatePickupRequested', () {
    final tRated = _makePickup(
      id: 'p-1',
      status: PickupStatus.completed,
      rating: 4.5,
      feedback: 'Great service',
    );

    blocTest<PickupBloc, PickupState>(
      'emits [PickupLoading, PickupRated] on success with feedback',
      build: _bloc,
      setUp: () {
        when(mockRepo.ratePickup(
          pickupId: 'p-1',
          rating: 4.5,
          feedback: 'Great service',
        )).thenAnswer((_) async => Right(tRated));
      },
      act: (bloc) => bloc.add(const RatePickupRequested(
        pickupId: 'p-1',
        rating: 4.5,
        feedback: 'Great service',
      )),
      expect: () => [
        const PickupLoading(),
        PickupRated(pickup: tRated),
      ],
      verify: (_) => verify(mockRepo.ratePickup(
        pickupId: 'p-1',
        rating: 4.5,
        feedback: 'Great service',
      )).called(1),
    );

    blocTest<PickupBloc, PickupState>(
      'emits [PickupLoading, PickupRated] on success without feedback',
      build: _bloc,
      setUp: () {
        when(mockRepo.ratePickup(
          pickupId: 'p-1',
          rating: 3.0,
          feedback: null,
        )).thenAnswer(
          (_) async => Right(_makePickup(id: 'p-1', rating: 3.0)),
        );
      },
      act: (bloc) => bloc.add(const RatePickupRequested(
        pickupId: 'p-1',
        rating: 3.0,
      )),
      expect: () => [
        const PickupLoading(),
        PickupRated(pickup: _makePickup(id: 'p-1', rating: 3.0)),
      ],
      verify: (_) => verify(mockRepo.ratePickup(
        pickupId: 'p-1',
        rating: 3.0,
        feedback: null,
      )).called(1),
    );

    for (final rating in [1.0, 2.0, 3.0, 4.0, 5.0]) {
      blocTest<PickupBloc, PickupState>(
        'rating=$rating is passed correctly to repository',
        build: _bloc,
        setUp: () {
          when(mockRepo.ratePickup(
            pickupId: 'p-1',
            rating: rating,
            feedback: null,
          )).thenAnswer(
            (_) async => Right(_makePickup(id: 'p-1', rating: rating)),
          );
        },
        act: (bloc) => bloc.add(RatePickupRequested(
          pickupId: 'p-1',
          rating: rating,
        )),
        expect: () => [
          const PickupLoading(),
          PickupRated(pickup: _makePickup(id: 'p-1', rating: rating)),
        ],
      );
    }

    blocTest<PickupBloc, PickupState>(
      'emits [PickupLoading, PickupError] on failure',
      build: _bloc,
      setUp: () {
        when(mockRepo.ratePickup(
          pickupId: 'p-1',
          rating: anyNamed('rating'),
          feedback: anyNamed('feedback'),
        )).thenAnswer((_) async => const Left(_tServerFailure));
      },
      act: (bloc) => bloc.add(const RatePickupRequested(
        pickupId: 'p-1',
        rating: 4.0,
      )),
      expect: () => [
        const PickupLoading(),
        const PickupError(message: 'Internal server error'),
      ],
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // VerifyPickupQrRequested (QR verification)
  // ══════════════════════════════════════════════════════════════════════════
  group('VerifyPickupQrRequested', () {
    final tVerified = _makePickup(
      id: 'p-1',
      status: PickupStatus.completed,
      qrToken: 'valid-qr-token',
    );

    blocTest<PickupBloc, PickupState>(
      'emits [PickupLoading, PickupQrVerified] on success',
      build: _bloc,
      setUp: () {
        when(mockRepo.verifyPickupQr(
          pickupId: 'p-1',
          qrToken: 'valid-qr-token',
        )).thenAnswer((_) async => Right(tVerified));
      },
      act: (bloc) => bloc.add(const VerifyPickupQrRequested(
        pickupId: 'p-1',
        qrToken: 'valid-qr-token',
      )),
      expect: () => [
        const PickupLoading(),
        PickupQrVerified(pickup: tVerified),
      ],
      verify: (_) => verify(mockRepo.verifyPickupQr(
        pickupId: 'p-1',
        qrToken: 'valid-qr-token',
      )).called(1),
    );

    blocTest<PickupBloc, PickupState>(
      'emits [PickupLoading, PickupError] on invalid QR token',
      build: _bloc,
      setUp: () {
        when(mockRepo.verifyPickupQr(
          pickupId: 'p-1',
          qrToken: 'invalid-token',
        )).thenAnswer(
          (_) async =>
              const Left(ServerFailure('Invalid QR token', 400, 'BAD_QR')),
        );
      },
      act: (bloc) => bloc.add(const VerifyPickupQrRequested(
        pickupId: 'p-1',
        qrToken: 'invalid-token',
      )),
      expect: () => [
        const PickupLoading(),
        const PickupError(message: 'Invalid QR token'),
      ],
    );

    blocTest<PickupBloc, PickupState>(
      'emits [PickupLoading, PickupError] on network failure during QR verify',
      build: _bloc,
      setUp: () {
        when(mockRepo.verifyPickupQr(
          pickupId: 'p-1',
          qrToken: 'any-token',
        )).thenAnswer((_) async => const Left(_tNetworkFailure));
      },
      act: (bloc) => bloc.add(const VerifyPickupQrRequested(
        pickupId: 'p-1',
        qrToken: 'any-token',
      )),
      expect: () => [
        const PickupLoading(),
        const PickupError(message: 'No internet connection'),
      ],
    );

    blocTest<PickupBloc, PickupState>(
      'verified pickup is available in PickupQrVerified state',
      build: _bloc,
      setUp: () {
        when(mockRepo.verifyPickupQr(
          pickupId: 'p-1',
          qrToken: 'tok',
        )).thenAnswer((_) async => Right(tVerified));
      },
      act: (bloc) => bloc.add(const VerifyPickupQrRequested(
        pickupId: 'p-1',
        qrToken: 'tok',
      )),
      expect: () => [
        const PickupLoading(),
        predicate<PickupState>(
            (s) => s is PickupQrVerified && s.pickup.id == 'p-1'),
      ],
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // RefreshTrackingRequested (live tracking — no Loading emitted)
  // ══════════════════════════════════════════════════════════════════════════
  group('RefreshTrackingRequested', () {
    final tTracked = _makePickup(
      id: 'p-1',
      status: PickupStatus.onTheWay,
      collectorLatitude: 9.03,
      collectorLongitude: 38.75,
      etaMinutes: 8,
    );

    blocTest<PickupBloc, PickupState>(
      'emits only [PickupTrackingUpdated] (no PickupLoading) on success',
      build: _bloc,
      setUp: () {
        when(mockRepo.getPickupTracking('p-1'))
            .thenAnswer((_) async => Right(tTracked));
      },
      act: (bloc) =>
          bloc.add(const RefreshTrackingRequested(pickupId: 'p-1')),
      expect: () => [PickupTrackingUpdated(pickup: tTracked)],
      verify: (_) =>
          verify(mockRepo.getPickupTracking('p-1')).called(1),
    );

    blocTest<PickupBloc, PickupState>(
      'emits [PickupError] (no PickupLoading) on failure',
      build: _bloc,
      setUp: () {
        when(mockRepo.getPickupTracking('p-1'))
            .thenAnswer((_) async => const Left(_tNetworkFailure));
      },
      act: (bloc) =>
          bloc.add(const RefreshTrackingRequested(pickupId: 'p-1')),
      expect: () => [
        const PickupError(message: 'No internet connection'),
      ],
    );

    blocTest<PickupBloc, PickupState>(
      'tracking data (eta, coordinates) reflected in state',
      build: _bloc,
      setUp: () {
        when(mockRepo.getPickupTracking('p-1'))
            .thenAnswer((_) async => Right(tTracked));
      },
      act: (bloc) =>
          bloc.add(const RefreshTrackingRequested(pickupId: 'p-1')),
      expect: () => [
        predicate<PickupState>((s) =>
            s is PickupTrackingUpdated &&
            s.pickup.etaMinutes == 8 &&
            s.pickup.collectorLatitude == 9.03 &&
            s.pickup.collectorLongitude == 38.75),
      ],
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // CancelRecurringScheduleRequested (recurring schedules)
  // ══════════════════════════════════════════════════════════════════════════
  group('CancelRecurringScheduleRequested', () {
    blocTest<PickupBloc, PickupState>(
      'emits [PickupLoading, RecurringScheduleCancelled] on success',
      build: _bloc,
      setUp: () {
        when(mockRepo.cancelRecurringSchedule('sched-1'))
            .thenAnswer((_) async => const Right(null));
      },
      act: (bloc) => bloc.add(
          const CancelRecurringScheduleRequested(scheduleId: 'sched-1')),
      expect: () => const [
        PickupLoading(),
        RecurringScheduleCancelled(),
      ],
      verify: (_) =>
          verify(mockRepo.cancelRecurringSchedule('sched-1')).called(1),
    );

    blocTest<PickupBloc, PickupState>(
      'emits [PickupLoading, PickupError] on failure',
      build: _bloc,
      setUp: () {
        when(mockRepo.cancelRecurringSchedule('sched-1'))
            .thenAnswer((_) async =>
                const Left(ServerFailure('Schedule not found', 404)));
      },
      act: (bloc) => bloc.add(
          const CancelRecurringScheduleRequested(scheduleId: 'sched-1')),
      expect: () => [
        const PickupLoading(),
        const PickupError(message: 'Schedule not found'),
      ],
    );

    blocTest<PickupBloc, PickupState>(
      'passes correct scheduleId to repository',
      build: _bloc,
      setUp: () {
        when(mockRepo.cancelRecurringSchedule('my-schedule-id'))
            .thenAnswer((_) async => const Right(null));
      },
      act: (bloc) => bloc.add(const CancelRecurringScheduleRequested(
          scheduleId: 'my-schedule-id')),
      verify: (_) =>
          verify(mockRepo.cancelRecurringSchedule('my-schedule-id')).called(1),
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Edge cases
  // ══════════════════════════════════════════════════════════════════════════
  group('Edge cases', () {
    blocTest<PickupBloc, PickupState>(
      'rapid load calls — second call still emits correct states',
      build: _bloc,
      setUp: () {
        when(mockRepo.getPickups()).thenAnswer(
          (_) async =>
              Right([_makePickup(id: 'p-1'), _makePickup(id: 'p-2')]),
        );
      },
      act: (bloc) async {
        bloc.add(const LoadPickupsRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const LoadPickupsRequested());
      },
      expect: () => [
        const PickupLoading(),
        isA<PickupLoaded>(),
        const PickupLoading(),
        isA<PickupLoaded>(),
      ],
    );

    blocTest<PickupBloc, PickupState>(
      'different failure types map to correct message',
      build: _bloc,
      setUp: () {
        when(mockRepo.getPickups()).thenAnswer(
          (_) async =>
              const Left(ValidationFailure('Bad params', {'field': 'val'})),
        );
      },
      act: (bloc) => bloc.add(const LoadPickupsRequested()),
      expect: () => [
        const PickupLoading(),
        const PickupError(message: 'Bad params'),
      ],
    );

    blocTest<PickupBloc, PickupState>(
      'AuthorizationFailure message is preserved in PickupError',
      build: _bloc,
      setUp: () {
        when(mockRepo.acceptPickup('p-1')).thenAnswer(
          (_) async =>
              const Left(AuthorizationFailure('Forbidden resource', 'FORBIDDEN')),
        );
      },
      act: (bloc) =>
          bloc.add(const AcceptPickupRequested(pickupId: 'p-1')),
      expect: () => [
        const PickupLoading(),
        const PickupError(message: 'Forbidden resource'),
      ],
    );

    blocTest<PickupBloc, PickupState>(
      'tracking refresh does not emit PickupLoading',
      build: _bloc,
      setUp: () {
        when(mockRepo.getPickupTracking('p-1')).thenAnswer(
          (_) async => Right(_makePickup(id: 'p-1')),
        );
      },
      act: (bloc) =>
          bloc.add(const RefreshTrackingRequested(pickupId: 'p-1')),
      expect: () => [
        isNot(const PickupLoading()),
      ],
    );

    blocTest<PickupBloc, PickupState>(
      'history hasMore boundary: exactly limit items → hasMore true',
      build: _bloc,
      setUp: () {
        when(mockRepo.getMyPickupHistory(page: 1, limit: 3)).thenAnswer(
          (_) async =>
              Right(List.generate(3, (i) => _makePickup(id: 'b-$i'))),
        );
      },
      act: (bloc) =>
          bloc.add(const LoadPickupHistoryRequested(page: 1, limit: 3)),
      expect: () => [
        const PickupLoading(),
        predicate<PickupState>((s) =>
            s is PickupHistoryLoaded &&
            s.hasMore == true &&
            s.pickups.length == 3),
      ],
    );

    blocTest<PickupBloc, PickupState>(
      'history hasMore boundary: one less than limit → hasMore false',
      build: _bloc,
      setUp: () {
        when(mockRepo.getMyPickupHistory(page: 1, limit: 3)).thenAnswer(
          (_) async =>
              Right(List.generate(2, (i) => _makePickup(id: 'c-$i'))),
        );
      },
      act: (bloc) =>
          bloc.add(const LoadPickupHistoryRequested(page: 1, limit: 3)),
      expect: () => [
        const PickupLoading(),
        predicate<PickupState>((s) =>
            s is PickupHistoryLoaded &&
            s.hasMore == false &&
            s.pickups.length == 2),
      ],
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // State equality
  // ══════════════════════════════════════════════════════════════════════════
  group('PickupState equality', () {
    final tPickup = _makePickup();

    test('PickupInitial equals PickupInitial', () {
      expect(const PickupInitial(), const PickupInitial());
    });

    test('PickupLoading equals PickupLoading', () {
      expect(const PickupLoading(), const PickupLoading());
    });

    test('PickupLoaded equals with same pickups', () {
      expect(
        PickupLoaded(pickups: [tPickup]),
        PickupLoaded(pickups: [tPickup]),
      );
    });

    test('PickupLoaded not equal with different pickups', () {
      expect(
        PickupLoaded(pickups: [tPickup]),
        isNot(PickupLoaded(pickups: [_makePickup(id: 'other')])),
      );
    });

    test('PickupError equals with same message', () {
      expect(
        const PickupError(message: 'err'),
        const PickupError(message: 'err'),
      );
    });

    test('PickupError not equal with different message', () {
      expect(
        const PickupError(message: 'a'),
        isNot(const PickupError(message: 'b')),
      );
    });

    test('CreatingPickup equals CreatingPickup', () {
      expect(const CreatingPickup(), const CreatingPickup());
    });

    test('PickupCreated equals with same pickup', () {
      expect(
        PickupCreated(pickup: tPickup),
        PickupCreated(pickup: tPickup),
      );
    });

    test('PickupStatusUpdated equals with same pickup', () {
      expect(
        PickupStatusUpdated(pickup: tPickup),
        PickupStatusUpdated(pickup: tPickup),
      );
    });

    test('PickupDetailLoaded equals with same pickup', () {
      expect(
        PickupDetailLoaded(pickup: tPickup),
        PickupDetailLoaded(pickup: tPickup),
      );
    });

    test('PickupHistoryLoaded equals with same fields', () {
      expect(
        PickupHistoryLoaded(pickups: [tPickup], currentPage: 1, hasMore: true),
        PickupHistoryLoaded(pickups: [tPickup], currentPage: 1, hasMore: true),
      );
    });

    test('PickupHistoryLoaded not equal when hasMore differs', () {
      expect(
        PickupHistoryLoaded(
            pickups: [tPickup], currentPage: 1, hasMore: true),
        isNot(PickupHistoryLoaded(
            pickups: [tPickup], currentPage: 1, hasMore: false)),
      );
    });

    test('PickupRated equals with same pickup', () {
      expect(PickupRated(pickup: tPickup), PickupRated(pickup: tPickup));
    });

    test('PickupQrVerified equals with same pickup', () {
      expect(
        PickupQrVerified(pickup: tPickup),
        PickupQrVerified(pickup: tPickup),
      );
    });

    test('PickupTrackingUpdated equals with same pickup', () {
      expect(
        PickupTrackingUpdated(pickup: tPickup),
        PickupTrackingUpdated(pickup: tPickup),
      );
    });

    test('RecurringScheduleCancelled equals RecurringScheduleCancelled', () {
      expect(
        const RecurringScheduleCancelled(),
        const RecurringScheduleCancelled(),
      );
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Event equality
  // ══════════════════════════════════════════════════════════════════════════
  group('PickupEvent equality', () {
    test('LoadPickupsRequested equals LoadPickupsRequested', () {
      expect(const LoadPickupsRequested(), const LoadPickupsRequested());
    });

    test('CreatePickupRequested equals with same fields', () {
      expect(
        const CreatePickupRequested(
          category: WasteCategory.plastic,
          estimatedWeight: 3.5,
          address: 'Addr',
        ),
        const CreatePickupRequested(
          category: WasteCategory.plastic,
          estimatedWeight: 3.5,
          address: 'Addr',
        ),
      );
    });

    test('LoadPickupDetailRequested equals with same id', () {
      expect(
        const LoadPickupDetailRequested(pickupId: 'x'),
        const LoadPickupDetailRequested(pickupId: 'x'),
      );
    });

    test('AcceptPickupRequested equals with same id', () {
      expect(
        const AcceptPickupRequested(pickupId: 'x'),
        const AcceptPickupRequested(pickupId: 'x'),
      );
    });

    test('UpdatePickupStatusRequested equals with same fields', () {
      expect(
        const UpdatePickupStatusRequested(
            pickupId: 'x', newStatus: PickupStatus.onTheWay),
        const UpdatePickupStatusRequested(
            pickupId: 'x', newStatus: PickupStatus.onTheWay),
      );
    });

    test('CompletePickupRequested equals with same id', () {
      expect(
        const CompletePickupRequested(pickupId: 'x'),
        const CompletePickupRequested(pickupId: 'x'),
      );
    });

    test('LoadPickupHistoryRequested equals with same page/limit', () {
      expect(
        const LoadPickupHistoryRequested(page: 2, limit: 10),
        const LoadPickupHistoryRequested(page: 2, limit: 10),
      );
    });

    test('RatePickupRequested equals with same fields', () {
      expect(
        const RatePickupRequested(
            pickupId: 'x', rating: 4.5, feedback: 'ok'),
        const RatePickupRequested(
            pickupId: 'x', rating: 4.5, feedback: 'ok'),
      );
    });

    test('VerifyPickupQrRequested equals with same fields', () {
      expect(
        const VerifyPickupQrRequested(pickupId: 'x', qrToken: 'tok'),
        const VerifyPickupQrRequested(pickupId: 'x', qrToken: 'tok'),
      );
    });

    test('RefreshTrackingRequested equals with same id', () {
      expect(
        const RefreshTrackingRequested(pickupId: 'x'),
        const RefreshTrackingRequested(pickupId: 'x'),
      );
    });

    test('CancelRecurringScheduleRequested equals with same id', () {
      expect(
        const CancelRecurringScheduleRequested(scheduleId: 's'),
        const CancelRecurringScheduleRequested(scheduleId: 's'),
      );
    });
  });
}
