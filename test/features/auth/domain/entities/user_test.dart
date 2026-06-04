import 'package:flutter_test/flutter_test.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/features/auth/domain/entities/user.dart';

void main() {
  final baseTime = DateTime(2024, 1, 15, 10, 0, 0);
  final updatedTime = DateTime(2024, 6, 1, 12, 0, 0);

  // Minimal valid user
  final minUser = User(
    id: 'u1',
    fullName: 'Alice',
    email: 'alice@example.com',
    role: UserRole.normalUser,
    createdAt: baseTime,
  );

  // Fully populated user
  final fullUser = User(
    id: 'u2',
    fullName: 'Bob Smith',
    email: 'bob@example.com',
    role: UserRole.collector,
    phoneNumber: '+8801700000000',
    profilePictureUrl: 'https://cdn.example.com/bob.jpg',
    ecoPoints: 750,
    createdAt: baseTime,
    updatedAt: updatedTime,
  );

  // ─────────────────────────────────────────────────────────
  // Construction & field access
  // ─────────────────────────────────────────────────────────
  group('User construction', () {
    test('required fields are stored correctly', () {
      expect(minUser.id, 'u1');
      expect(minUser.fullName, 'Alice');
      expect(minUser.email, 'alice@example.com');
      expect(minUser.role, UserRole.normalUser);
      expect(minUser.createdAt, baseTime);
    });

    test('optional fields default to null / 0', () {
      expect(minUser.phoneNumber, isNull);
      expect(minUser.profilePictureUrl, isNull);
      expect(minUser.ecoPoints, 0);
      expect(minUser.updatedAt, isNull);
    });

    test('fully populated user stores all fields', () {
      expect(fullUser.id, 'u2');
      expect(fullUser.fullName, 'Bob Smith');
      expect(fullUser.email, 'bob@example.com');
      expect(fullUser.role, UserRole.collector);
      expect(fullUser.phoneNumber, '+8801700000000');
      expect(fullUser.profilePictureUrl, 'https://cdn.example.com/bob.jpg');
      expect(fullUser.ecoPoints, 750);
      expect(fullUser.createdAt, baseTime);
      expect(fullUser.updatedAt, updatedTime);
    });
  });

  // ─────────────────────────────────────────────────────────
  // Equality (Equatable)
  // ─────────────────────────────────────────────────────────
  group('User equality', () {
    test('same data → equal', () {
      final u1 = User(
        id: 'x',
        fullName: 'Test',
        email: 't@t.com',
        role: UserRole.buyer,
        createdAt: baseTime,
      );
      final u2 = User(
        id: 'x',
        fullName: 'Test',
        email: 't@t.com',
        role: UserRole.buyer,
        createdAt: baseTime,
      );
      expect(u1, equals(u2));
    });

    test('different id → not equal', () {
      expect(
        minUser == minUser.copyWith(id: 'other'),
        isFalse,
      );
    });

    test('different role → not equal', () {
      expect(
        minUser == minUser.copyWith(role: UserRole.buyer),
        isFalse,
      );
    });

    test('different ecoPoints → not equal', () {
      expect(
        fullUser == fullUser.copyWith(ecoPoints: 0),
        isFalse,
      );
    });

    test('hashCode is consistent with equality', () {
      final u1 = User(
        id: 'abc',
        fullName: 'X',
        email: 'x@x.com',
        role: UserRole.buyer,
        createdAt: baseTime,
      );
      final u2 = User(
        id: 'abc',
        fullName: 'X',
        email: 'x@x.com',
        role: UserRole.buyer,
        createdAt: baseTime,
      );
      expect(u1.hashCode, u2.hashCode);
    });
  });

  // ─────────────────────────────────────────────────────────
  // copyWith
  // ─────────────────────────────────────────────────────────
  group('User.copyWith', () {
    test('no arguments returns equivalent object', () {
      expect(minUser.copyWith(), equals(minUser));
    });

    test('changing id only', () {
      final copy = minUser.copyWith(id: 'new-id');
      expect(copy.id, 'new-id');
      expect(copy.fullName, minUser.fullName);
      expect(copy.email, minUser.email);
      expect(copy.role, minUser.role);
    });

    test('changing fullName only', () {
      final copy = minUser.copyWith(fullName: 'Charlie');
      expect(copy.fullName, 'Charlie');
      expect(copy.id, minUser.id);
    });

    test('changing role only', () {
      final copy = minUser.copyWith(role: UserRole.collector);
      expect(copy.role, UserRole.collector);
    });

    test('setting ecoPoints', () {
      final copy = minUser.copyWith(ecoPoints: 500);
      expect(copy.ecoPoints, 500);
    });

    test('setting phoneNumber', () {
      final copy = minUser.copyWith(phoneNumber: '+1234567890');
      expect(copy.phoneNumber, '+1234567890');
    });

    test('setting updatedAt', () {
      final copy = minUser.copyWith(updatedAt: updatedTime);
      expect(copy.updatedAt, updatedTime);
    });

    test('changing multiple fields at once', () {
      final copy = minUser.copyWith(
        fullName: 'Dave',
        ecoPoints: 100,
        role: UserRole.buyer,
        updatedAt: updatedTime,
      );
      expect(copy.fullName, 'Dave');
      expect(copy.ecoPoints, 100);
      expect(copy.role, UserRole.buyer);
      expect(copy.updatedAt, updatedTime);
      // unchanged fields preserved
      expect(copy.id, minUser.id);
      expect(copy.email, minUser.email);
    });

    test('copyWith does not mutate original', () {
      final original = minUser.copyWith();
      minUser.copyWith(fullName: 'Changed');
      expect(minUser.fullName, 'Alice');
      expect(original.fullName, 'Alice');
    });
  });

  // ─────────────────────────────────────────────────────────
  // Edge / boundary cases
  // ─────────────────────────────────────────────────────────
  group('User edge cases', () {
    test('ecoPoints can be 0', () {
      final u = minUser.copyWith(ecoPoints: 0);
      expect(u.ecoPoints, 0);
    });

    test('ecoPoints can be very large', () {
      final u = minUser.copyWith(ecoPoints: 999999);
      expect(u.ecoPoints, 999999);
    });

    test('empty string id is valid (entity does not validate)', () {
      final u = minUser.copyWith(id: '');
      expect(u.id, '');
    });

    test('all UserRole values can be assigned', () {
      for (final role in UserRole.values) {
        final u = minUser.copyWith(role: role);
        expect(u.role, role);
      }
    });

    test('profilePictureUrl can be set and cleared via new object', () {
      final withPic = minUser.copyWith(profilePictureUrl: 'https://img.com/p.jpg');
      expect(withPic.profilePictureUrl, 'https://img.com/p.jpg');
    });
  });
}
