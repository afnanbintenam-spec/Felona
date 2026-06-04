import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/pickup/domain/entities/pickup_request.dart';
import 'package:felo_na/features/pickup/domain/repositories/pickup_repository.dart';
import 'package:felo_na/features/pickup/domain/usecases/get_pickups_usecase.dart';
import 'package:felo_na/features/pickup/domain/usecases/create_pickup_usecase.dart';
import 'package:felo_na/features/pickup/domain/usecases/accept_pickup_usecase.dart';
import 'package:felo_na/features/pickup/domain/usecases/rate_pickup_usecase.dart';
import 'package:felo_na/features/pickup/domain/usecases/verify_pickup_qr_usecase.dart';
import 'package:felo_na/features/pickup/domain/usecases/get_pickup_history_usecase.dart';

import 'pickup_usecases_test.mocks.dart';

@GenerateMocks([PickupRepository])
void main() {
  late MockPickupRepository mockRepository;

  // ── shared test fixture ─────────────────────────────────────────────────
  final tPickup = PickupRequest(
    id: 'pickup-1',
    userId: 'user-1',
    userName: 'Karim',
    category: WasteCategory.plastic,
    estimatedWeight: 3.5,
    address: '12 Mirpur Road, Dhaka',
    status: PickupStatus.pending,
    createdAt: DateTime(2025, 3, 15),
  );

  setUp(() {
    mockRepository = MockPickupRepository();
  });

  // ── GetPickupsUseCase ───────────────────────────────────────────────────
  group('GetPickupsUseCase', () {
    late GetPickupsUseCase useCase;

    setUp(() => useCase = GetPickupsUseCase(mockRepository));

    test('returns list of pickups on success', () async {
      when(mockRepository.getPickups())
          .thenAnswer((_) async => Right<Failure, List<PickupRequest>>([tPickup]));

      final result = await useCase(const NoParams());

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right but got Left'),
        (pickups) => expect(pickups, [tPickup]),
      );
      verify(mockRepository.getPickups()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('returns NetworkFailure when offline', () async {
      when(mockRepository.getPickups()).thenAnswer(
        (_) async => const Left(NetworkFailure('No internet')),
      );

      final result = await useCase(const NoParams());

      expect(result, const Left(NetworkFailure('No internet')));
    });
  });

  // ── CreatePickupUseCase ─────────────────────────────────────────────────
  group('CreatePickupUseCase', () {
    late CreatePickupUseCase useCase;

    setUp(() => useCase = CreatePickupUseCase(mockRepository));

    const tParams = CreatePickupParams(
      category: WasteCategory.plastic,
      estimatedWeight: 3.5,
      address: '12 Mirpur Road, Dhaka',
    );

    test('returns created pickup on success', () async {
      when(mockRepository.createPickup(
        category: tParams.category,
        estimatedWeight: tParams.estimatedWeight,
        address: tParams.address,
        latitude: null,
        longitude: null,
        notes: null,
        scheduledDate: null,
        timeSlot: null,
        isRecurring: false,
        recurrenceFrequency: null,
        recurrenceDayOfWeek: null,
      )).thenAnswer((_) async => Right(tPickup));

      final result = await useCase(tParams);

      expect(result, Right(tPickup));
      verify(mockRepository.createPickup(
        category: WasteCategory.plastic,
        estimatedWeight: 3.5,
        address: '12 Mirpur Road, Dhaka',
        latitude: null,
        longitude: null,
        notes: null,
        scheduledDate: null,
        timeSlot: null,
        isRecurring: false,
        recurrenceFrequency: null,
        recurrenceDayOfWeek: null,
      )).called(1);
    });

    test('returns ValidationFailure when address is empty', () async {
      const emptyAddr = CreatePickupParams(
        category: WasteCategory.plastic,
        estimatedWeight: 1.0,
        address: '',
      );
      when(mockRepository.createPickup(
        category: WasteCategory.plastic,
        estimatedWeight: 1.0,
        address: '',
        latitude: null,
        longitude: null,
        notes: null,
        scheduledDate: null,
        timeSlot: null,
        isRecurring: false,
        recurrenceFrequency: null,
        recurrenceDayOfWeek: null,
      )).thenAnswer(
        (_) async => const Left(
          ValidationFailure('Address required', {'address': 'required'}),
        ),
      );

      final result = await useCase(emptyAddr);

      expect(result.isLeft(), true);
    });

    test('CreatePickupParams supports value equality', () {
      const p1 = CreatePickupParams(
        category: WasteCategory.metal,
        estimatedWeight: 2.0,
        address: 'Test',
      );
      const p2 = CreatePickupParams(
        category: WasteCategory.metal,
        estimatedWeight: 2.0,
        address: 'Test',
      );
      expect(p1, equals(p2));
    });
  });

  // ── AcceptPickupUseCase ─────────────────────────────────────────────────
  group('AcceptPickupUseCase', () {
    late AcceptPickupUseCase useCase;

    setUp(() => useCase = AcceptPickupUseCase(mockRepository));

    test('returns accepted pickup on success', () async {
      final accepted = tPickup.copyWith(status: PickupStatus.accepted);
      when(mockRepository.acceptPickup('pickup-1'))
          .thenAnswer((_) async => Right(accepted));

      final result =
          await useCase(const AcceptPickupParams(pickupId: 'pickup-1'));

      expect(result, Right(accepted));
      verify(mockRepository.acceptPickup('pickup-1')).called(1);
    });

    test('returns AuthorizationFailure when collector not eligible', () async {
      when(mockRepository.acceptPickup('pickup-1')).thenAnswer(
        (_) async => const Left(AuthorizationFailure('Not allowed')),
      );

      final result =
          await useCase(const AcceptPickupParams(pickupId: 'pickup-1'));

      expect(result, const Left(AuthorizationFailure('Not allowed')));
    });
  });

  // ── RatePickupUseCase ───────────────────────────────────────────────────
  group('RatePickupUseCase', () {
    late RatePickupUseCase useCase;

    setUp(() => useCase = RatePickupUseCase(mockRepository));

    test('returns rated pickup on success', () async {
      final rated = tPickup.copyWith(rating: 4.5, feedback: 'Great service');
      when(mockRepository.ratePickup(
        pickupId: 'pickup-1',
        rating: 4.5,
        feedback: 'Great service',
      )).thenAnswer((_) async => Right(rated));

      final result = await useCase(const RatePickupParams(
        pickupId: 'pickup-1',
        rating: 4.5,
        feedback: 'Great service',
      ));

      expect(result, Right(rated));
    });
  });

  // ── VerifyPickupQrUseCase ───────────────────────────────────────────────
  group('VerifyPickupQrUseCase', () {
    late VerifyPickupQrUseCase useCase;

    setUp(() => useCase = VerifyPickupQrUseCase(mockRepository));

    test('returns completed pickup when QR is valid', () async {
      final completed = tPickup.copyWith(status: PickupStatus.completed);
      when(mockRepository.verifyPickupQr(
        pickupId: 'pickup-1',
        qrToken: 'valid-token',
      )).thenAnswer((_) async => Right(completed));

      final result = await useCase(const VerifyPickupQrParams(
        pickupId: 'pickup-1',
        qrToken: 'valid-token',
      ));

      expect(result, Right(completed));
    });

    test('returns ServerFailure when QR token is invalid', () async {
      when(mockRepository.verifyPickupQr(
        pickupId: 'pickup-1',
        qrToken: 'bad-token',
      )).thenAnswer(
        (_) async => const Left(ServerFailure('Invalid QR token', 400)),
      );

      final result = await useCase(const VerifyPickupQrParams(
        pickupId: 'pickup-1',
        qrToken: 'bad-token',
      ));

      expect(result.isLeft(), true);
    });
  });

  // ── GetPickupHistoryUseCase ─────────────────────────────────────────────
  group('GetPickupHistoryUseCase', () {
    late GetPickupHistoryUseCase useCase;

    setUp(() => useCase = GetPickupHistoryUseCase(mockRepository));

    test('returns history with default pagination', () async {
      when(mockRepository.getMyPickupHistory(page: 1, limit: 20))
          .thenAnswer((_) async => Right<Failure, List<PickupRequest>>([tPickup]));

      final result = await useCase(const GetPickupHistoryParams());

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right but got Left'),
        (pickups) => expect(pickups, [tPickup]),
      );
      verify(mockRepository.getMyPickupHistory(page: 1, limit: 20)).called(1);
    });

    test('passes custom page and limit to repository', () async {
      when(mockRepository.getMyPickupHistory(page: 2, limit: 10))
          .thenAnswer((_) async => Right<Failure, List<PickupRequest>>([]));

      final result = await useCase(
        const GetPickupHistoryParams(page: 2, limit: 10),
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected Right but got Left'),
        (pickups) => expect(pickups, isEmpty),
      );
      verify(mockRepository.getMyPickupHistory(page: 2, limit: 10)).called(1);
    });
  });
}
