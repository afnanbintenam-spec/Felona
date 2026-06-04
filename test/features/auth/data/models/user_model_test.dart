import 'package:flutter_test/flutter_test.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/features/auth/data/models/user_model.dart';
import 'package:felo_na/features/auth/domain/entities/user.dart';

void main() {
  // ─── shared fixtures ──────────────────────────────────────
  final createdAt = DateTime.utc(2024, 1, 15, 10, 0, 0);
  final updatedAt = DateTime.utc(2024, 6, 1, 12, 0, 0);

  Map<String, dynamic> fullSnakeJson() => {
        'id': 'u1',
        'full_name': 'Alice Smith',
        'email': 'alice@example.com',
        'role': 'normal_user',
        'phone_number': '+8801700000000',
        'profile_picture_url': 'https://cdn/alice.jpg',
        'eco_points': 350,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  Map<String, dynamic> fullCamelJson() => {
        'id': 'u1',
        'fullName': 'Alice Smith',
        'email': 'alice@example.com',
        'role': 'buyer',
        'phoneNumber': '+8801700000000',
        'profilePictureUrl': 'https://cdn/alice.jpg',
        'ecoPoints': 350,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  // ─────────────────────────────────────────────────────────
  // fromJson — snake_case
  // ─────────────────────────────────────────────────────────
  group('UserModel.fromJson snake_case', () {
    test('parses all required fields', () {
      final m = UserModel.fromJson(fullSnakeJson());
      expect(m.id, 'u1');
      expect(m.fullName, 'Alice Smith');
      expect(m.email, 'alice@example.com');
      expect(m.role, UserRole.normalUser);
      expect(m.ecoPoints, 350);
      expect(m.createdAt, createdAt);
    });

    test('parses optional fields', () {
      final m = UserModel.fromJson(fullSnakeJson());
      expect(m.phoneNumber, '+8801700000000');
      expect(m.profilePictureUrl, 'https://cdn/alice.jpg');
      expect(m.updatedAt, updatedAt);
    });

    test('null optional fields are null', () {
      final json = {
        'id': 'u2',
        'full_name': 'Bob',
        'email': 'b@b.com',
        'role': 'collector',
        'created_at': createdAt.toIso8601String(),
      };
      final m = UserModel.fromJson(json);
      expect(m.phoneNumber, isNull);
      expect(m.profilePictureUrl, isNull);
      expect(m.updatedAt, isNull);
    });

    test('eco_points defaults to 0 when absent', () {
      final json = {
        'id': 'u3',
        'full_name': 'Carol',
        'email': 'c@c.com',
        'role': 'buyer',
        'created_at': createdAt.toIso8601String(),
      };
      final m = UserModel.fromJson(json);
      expect(m.ecoPoints, 0);
    });

    test('eco_points as int parses correctly', () {
      final json = {...fullSnakeJson(), 'eco_points': 100};
      expect(UserModel.fromJson(json).ecoPoints, 100);
    });
  });

  // ─────────────────────────────────────────────────────────
  // fromJson — camelCase fallback
  // ─────────────────────────────────────────────────────────
  group('UserModel.fromJson camelCase fallback', () {
    test('fullName via camelCase key', () {
      expect(UserModel.fromJson(fullCamelJson()).fullName, 'Alice Smith');
    });

    test('role via camelCase key', () {
      expect(UserModel.fromJson(fullCamelJson()).role, UserRole.buyer);
    });

    test('phoneNumber via camelCase key', () {
      expect(UserModel.fromJson(fullCamelJson()).phoneNumber, '+8801700000000');
    });

    test('ecoPoints via camelCase key', () {
      expect(UserModel.fromJson(fullCamelJson()).ecoPoints, 350);
    });

    test('createdAt via camelCase key', () {
      expect(UserModel.fromJson(fullCamelJson()).createdAt, createdAt);
    });

    test('updatedAt via camelCase key', () {
      expect(UserModel.fromJson(fullCamelJson()).updatedAt, updatedAt);
    });
  });

  // ─────────────────────────────────────────────────────────
  // Role parsing
  // ─────────────────────────────────────────────────────────
  group('UserModel role parsing', () {
    for (final entry in {
      'normal_user': UserRole.normalUser,
      'NORMAL_USER': UserRole.normalUser,
      'Normal_User': UserRole.normalUser,
      'buyer': UserRole.buyer,
      'BUYER': UserRole.buyer,
      'collector': UserRole.collector,
      'COLLECTOR': UserRole.collector,
    }.entries) {
      test('"${entry.key}" → ${entry.value}', () {
        final json = {...fullSnakeJson(), 'role': entry.key};
        expect(UserModel.fromJson(json).role, entry.value);
      });
    }

    test('unknown role throws FormatException', () {
      final json = {...fullSnakeJson(), 'role': 'admin'};
      expect(() => UserModel.fromJson(json), throwsA(isA<FormatException>()));
    });
  });

  // ─────────────────────────────────────────────────────────
  // toJson
  // ─────────────────────────────────────────────────────────
  group('UserModel.toJson', () {
    test('produces snake_case keys', () {
      final m = UserModel.fromJson(fullSnakeJson());
      final j = m.toJson();
      expect(j.containsKey('full_name'), isTrue);
      expect(j.containsKey('phone_number'), isTrue);
      expect(j.containsKey('profile_picture_url'), isTrue);
      expect(j.containsKey('eco_points'), isTrue);
      expect(j.containsKey('created_at'), isTrue);
      expect(j.containsKey('updated_at'), isTrue);
    });

    test('role serialises as normal_user', () {
      final m = UserModel.fromJson(fullSnakeJson());
      expect(m.toJson()['role'], 'normal_user');
    });

    test('role serialises as buyer', () {
      final m = UserModel.fromJson({...fullSnakeJson(), 'role': 'buyer'});
      expect(m.toJson()['role'], 'buyer');
    });

    test('role serialises as collector', () {
      final m = UserModel.fromJson({...fullSnakeJson(), 'role': 'collector'});
      expect(m.toJson()['role'], 'collector');
    });

    test('null updatedAt serialises as null', () {
      final json = {...fullSnakeJson()..remove('updated_at')};
      final m = UserModel.fromJson(json);
      expect(m.toJson()['updated_at'], isNull);
    });

    test('null phoneNumber serialises as null', () {
      final json = Map<String, dynamic>.from(fullSnakeJson())
        ..remove('phone_number');
      final m = UserModel.fromJson(json);
      expect(m.toJson()['phone_number'], isNull);
    });

    test('eco_points serialises as int', () {
      final m = UserModel.fromJson(fullSnakeJson());
      expect(m.toJson()['eco_points'], isA<int>());
      expect(m.toJson()['eco_points'], 350);
    });
  });

  // ─────────────────────────────────────────────────────────
  // Round-trip: fromJson → toJson → fromJson
  // ─────────────────────────────────────────────────────────
  group('UserModel round-trip', () {
    test('full object survives fromJson → toJson → fromJson', () {
      final original = UserModel.fromJson(fullSnakeJson());
      final roundTripped = UserModel.fromJson(original.toJson());
      expect(roundTripped, equals(original));
    });

    test('minimal object (no optionals) survives round-trip', () {
      final json = {
        'id': 'u9',
        'full_name': 'Min',
        'email': 'm@m.com',
        'role': 'buyer',
        'created_at': createdAt.toIso8601String(),
      };
      final original = UserModel.fromJson(json);
      final roundTripped = UserModel.fromJson(original.toJson());
      expect(roundTripped, equals(original));
    });
  });

  // ─────────────────────────────────────────────────────────
  // fromEntity
  // ─────────────────────────────────────────────────────────
  group('UserModel.fromEntity', () {
    test('wraps a User entity correctly', () {
      final entity = User(
        id: 'eid',
        fullName: 'Eve',
        email: 'eve@example.com',
        role: UserRole.collector,
        phoneNumber: '+1',
        profilePictureUrl: 'https://img/e.jpg',
        ecoPoints: 999,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
      final model = UserModel.fromEntity(entity);
      expect(model.id, entity.id);
      expect(model.fullName, entity.fullName);
      expect(model.email, entity.email);
      expect(model.role, entity.role);
      expect(model.phoneNumber, entity.phoneNumber);
      expect(model.profilePictureUrl, entity.profilePictureUrl);
      expect(model.ecoPoints, entity.ecoPoints);
      expect(model.createdAt, entity.createdAt);
      expect(model.updatedAt, entity.updatedAt);
    });

    test('fromEntity preserves same props as source entity', () {
      final entity = User(
        id: 'x',
        fullName: 'X',
        email: 'x@x.com',
        role: UserRole.buyer,
        createdAt: createdAt,
      );
      final model = UserModel.fromEntity(entity);
      // UserModel extends User; their field values are identical
      expect(model.id, entity.id);
      expect(model.fullName, entity.fullName);
      expect(model.email, entity.email);
      expect(model.role, entity.role);
      expect(model.ecoPoints, entity.ecoPoints);
      expect(model.createdAt, entity.createdAt);
    });

    test('fromEntity on minimal entity has null optionals', () {
      final entity = User(
        id: 'min',
        fullName: 'Min',
        email: 'min@min.com',
        role: UserRole.normalUser,
        createdAt: createdAt,
      );
      final model = UserModel.fromEntity(entity);
      expect(model.phoneNumber, isNull);
      expect(model.profilePictureUrl, isNull);
      expect(model.updatedAt, isNull);
      expect(model.ecoPoints, 0);
    });
  });

  // ─────────────────────────────────────────────────────────
  // Equality & type checks
  // ─────────────────────────────────────────────────────────
  group('UserModel is-a User', () {
    test('UserModel is a User', () {
      expect(UserModel.fromJson(fullSnakeJson()), isA<User>());
    });
  });
}
