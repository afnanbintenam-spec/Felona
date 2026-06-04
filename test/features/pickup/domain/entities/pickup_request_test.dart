import 'package:flutter_test/flutter_test.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/features/pickup/domain/entities/pickup_request.dart';

void main() {
  final baseTime = DateTime(2024, 3, 10, 9, 0, 0);
  final scheduled = DateTime(2024, 3, 12, 0, 0, 0);
  final accepted = DateTime(2024, 3, 12, 8, 30, 0);
  final completed = DateTime(2024, 3, 12, 9, 15, 0);

  // Minimal valid pickup request
  PickupRequest makeMin() => PickupRequest(
        id: 'pr1',
        userId: 'u1',
        userName: 'Alice',
        category: WasteCategory.plastic,
        estimatedWeight: 5.0,
        address: '123 Green St',
        status: PickupStatus.pending,
        createdAt: baseTime,
      );

  // Fully populated pickup request
  PickupRequest makeFull() => PickupRequest(
        id: 'pr2',
        userId: 'u2',
        userName: 'Bob',
        category: WasteCategory.metal,
        estimatedWeight: 12.5,
        address: '456 Eco Ave',
        latitude: 23.8103,
        longitude: 90.4125,
        notes: 'Leave at gate',
        status: PickupStatus.accepted,
        collectorId: 'c1',
        collectorName: 'Charlie',
        collectorPhone: '+8801800000000',
        collectorPhoto: 'https://img/c.jpg',
        collectorRating: 4.8,
        createdAt: baseTime,
        scheduledDate: scheduled,
        timeSlot: PickupTimeSlot.morning1,
        isRecurring: true,
        recurrenceFrequency: RecurrenceFrequency.weekly,
        recurrenceDayOfWeek: 2,
        recurringScheduleId: 'rs1',
        acceptedAt: accepted,
        completedAt: completed,
        ecoPointsEarned: 50,
        etaMinutes: 15,
        collectorLatitude: 23.8100,
        collectorLongitude: 90.4120,
        qrToken: 'qr-abc-123',
        rating: 5.0,
        feedback: 'Great service',
      );

  // ─────────────────────────────────────────────────────────
  // Construction & field access
  // ─────────────────────────────────────────────────────────
  group('PickupRequest construction', () {
    test('required fields stored correctly', () {
      final req = makeMin();
      expect(req.id, 'pr1');
      expect(req.userId, 'u1');
      expect(req.userName, 'Alice');
      expect(req.category, WasteCategory.plastic);
      expect(req.estimatedWeight, 5.0);
      expect(req.address, '123 Green St');
      expect(req.status, PickupStatus.pending);
      expect(req.createdAt, baseTime);
    });

    test('optional fields default correctly', () {
      final req = makeMin();
      expect(req.latitude, isNull);
      expect(req.longitude, isNull);
      expect(req.notes, isNull);
      expect(req.collectorId, isNull);
      expect(req.collectorName, isNull);
      expect(req.collectorPhone, isNull);
      expect(req.collectorPhoto, isNull);
      expect(req.collectorRating, isNull);
      expect(req.scheduledDate, isNull);
      expect(req.timeSlot, isNull);
      expect(req.isRecurring, isFalse);
      expect(req.recurrenceFrequency, isNull);
      expect(req.recurrenceDayOfWeek, isNull);
      expect(req.recurringScheduleId, isNull);
      expect(req.acceptedAt, isNull);
      expect(req.completedAt, isNull);
      expect(req.ecoPointsEarned, isNull);
      expect(req.etaMinutes, isNull);
      expect(req.collectorLatitude, isNull);
      expect(req.collectorLongitude, isNull);
      expect(req.qrToken, isNull);
      expect(req.rating, isNull);
      expect(req.feedback, isNull);
    });

    test('fully populated request stores all fields', () {
      final req = makeFull();
      expect(req.latitude, 23.8103);
      expect(req.longitude, 90.4125);
      expect(req.notes, 'Leave at gate');
      expect(req.collectorId, 'c1');
      expect(req.collectorRating, 4.8);
      expect(req.scheduledDate, scheduled);
      expect(req.timeSlot, PickupTimeSlot.morning1);
      expect(req.isRecurring, isTrue);
      expect(req.recurrenceFrequency, RecurrenceFrequency.weekly);
      expect(req.recurrenceDayOfWeek, 2);
      expect(req.recurringScheduleId, 'rs1');
      expect(req.acceptedAt, accepted);
      expect(req.completedAt, completed);
      expect(req.ecoPointsEarned, 50);
      expect(req.etaMinutes, 15);
      expect(req.collectorLatitude, 23.8100);
      expect(req.collectorLongitude, 90.4120);
      expect(req.qrToken, 'qr-abc-123');
      expect(req.rating, 5.0);
      expect(req.feedback, 'Great service');
    });
  });

  // ─────────────────────────────────────────────────────────
  // Equality (Equatable)
  // ─────────────────────────────────────────────────────────
  group('PickupRequest equality', () {
    test('identical data → equal', () {
      expect(makeMin(), equals(makeMin()));
    });

    test('different id → not equal', () {
      expect(makeMin() == makeMin().copyWith(id: 'different'), isFalse);
    });

    test('different status → not equal', () {
      expect(
        makeMin() == makeMin().copyWith(status: PickupStatus.completed),
        isFalse,
      );
    });

    test('different category → not equal', () {
      expect(
        makeMin() == makeMin().copyWith(category: WasteCategory.glass),
        isFalse,
      );
    });

    test('hashCode consistent with equality', () {
      expect(makeMin().hashCode, makeMin().hashCode);
    });
  });

  // ─────────────────────────────────────────────────────────
  // copyWith
  // ─────────────────────────────────────────────────────────
  group('PickupRequest.copyWith', () {
    test('no args returns equivalent object', () {
      expect(makeMin().copyWith(), equals(makeMin()));
    });

    test('changing status only', () {
      final copy = makeMin().copyWith(status: PickupStatus.completed);
      expect(copy.status, PickupStatus.completed);
      expect(copy.id, 'pr1');
    });

    test('assigning collector fields', () {
      final copy = makeMin().copyWith(
        collectorId: 'c99',
        collectorName: 'Dave',
        collectorPhone: '+111',
        status: PickupStatus.accepted,
      );
      expect(copy.collectorId, 'c99');
      expect(copy.collectorName, 'Dave');
      expect(copy.status, PickupStatus.accepted);
    });

    test('marking as recurring', () {
      final copy = makeMin().copyWith(
        isRecurring: true,
        recurrenceFrequency: RecurrenceFrequency.biweekly,
        recurrenceDayOfWeek: 5,
      );
      expect(copy.isRecurring, isTrue);
      expect(copy.recurrenceFrequency, RecurrenceFrequency.biweekly);
      expect(copy.recurrenceDayOfWeek, 5);
    });

    test('setting eco points earned', () {
      final copy = makeMin().copyWith(ecoPointsEarned: 30);
      expect(copy.ecoPointsEarned, 30);
    });

    test('setting coordinates', () {
      final copy = makeMin().copyWith(latitude: 23.0, longitude: 90.0);
      expect(copy.latitude, 23.0);
      expect(copy.longitude, 90.0);
    });

    test('setting qrToken', () {
      final copy = makeMin().copyWith(qrToken: 'tok-xyz');
      expect(copy.qrToken, 'tok-xyz');
    });

    test('changing all fields at once preserves unchanged fields', () {
      final copy = makeFull().copyWith(
        status: PickupStatus.cancelled,
        feedback: 'Cancelled by user',
      );
      expect(copy.status, PickupStatus.cancelled);
      expect(copy.feedback, 'Cancelled by user');
      // unchanged
      expect(copy.id, 'pr2');
      expect(copy.category, WasteCategory.metal);
      expect(copy.isRecurring, isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────
  // Boundary / edge cases
  // ─────────────────────────────────────────────────────────
  group('PickupRequest boundary cases', () {
    test('estimatedWeight of 0.0 is valid', () {
      final req = makeMin().copyWith(estimatedWeight: 0.0);
      expect(req.estimatedWeight, 0.0);
    });

    test('very large estimatedWeight is valid', () {
      final req = makeMin().copyWith(estimatedWeight: 9999.99);
      expect(req.estimatedWeight, 9999.99);
    });

    test('recurrenceDayOfWeek boundary: 1 (Monday)', () {
      final req = makeMin().copyWith(recurrenceDayOfWeek: 1);
      expect(req.recurrenceDayOfWeek, 1);
    });

    test('recurrenceDayOfWeek boundary: 7 (Sunday)', () {
      final req = makeMin().copyWith(recurrenceDayOfWeek: 7);
      expect(req.recurrenceDayOfWeek, 7);
    });

    test('rating boundary: 1.0', () {
      final req = makeMin().copyWith(rating: 1.0);
      expect(req.rating, 1.0);
    });

    test('rating boundary: 5.0', () {
      final req = makeMin().copyWith(rating: 5.0);
      expect(req.rating, 5.0);
    });

    test('all PickupStatus values can be assigned', () {
      for (final s in PickupStatus.values) {
        final req = makeMin().copyWith(status: s);
        expect(req.status, s);
      }
    });

    test('all WasteCategory values can be assigned', () {
      for (final c in WasteCategory.values) {
        final req = makeMin().copyWith(category: c);
        expect(req.category, c);
      }
    });

    test('all PickupTimeSlot values can be assigned', () {
      for (final t in PickupTimeSlot.values) {
        final req = makeMin().copyWith(timeSlot: t);
        expect(req.timeSlot, t);
      }
    });
  });
}
