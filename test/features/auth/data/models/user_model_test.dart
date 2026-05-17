import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/features/auth/data/models/user_model.dart';
import 'package:felo_na/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tCreatedAt = DateTime(2024, 1, 15, 10, 30, 0);
  final tUpdatedAt = DateTime(2024, 2, 20, 14, 45, 0);

  final tUserModel = UserModel(
    id: 'user-123',
    fullName: 'John Doe',
    email: 'john@example.com',
    role: UserRole.normalUser,
    phoneNumber: '+201234567890',
    profilePictureUrl: 'https://example.com/pic.jpg',
    ecoPoints: 150,
    createdAt: tCreatedAt,
    updatedAt: tUpdatedAt,
  );

  final tJsonMap = {
    'id': 'user-123',
    'full_name': 'John Doe',
    'email': 'john@example.com',
    'role': 'normal_user',
    'phone_number': '+201234567890',
    'profile_picture_url': 'https://example.com/pic.jpg',
    'eco_points': 150,
    'created_at': '2024-01-15T10:30:00.000',
    'updated_at': '2024-02-20T14:45:00.000',
  };

  group('UserModel', () {
    test('should be a subclass of User entity', () {
      expect(tUserModel, isA<User>());
    });

    group('fromJson', () {
      test('should return a valid UserModel from JSON with all fields', () {
        final result = UserModel.fromJson(tJsonMap);

        expect(result.id, 'user-123');
        expect(result.fullName, 'John Doe');
        expect(result.email, 'john@example.com');
        expect(result.role, UserRole.normalUser);
        expect(result.phoneNumber, '+201234567890');
        expect(result.profilePictureUrl, 'https://example.com/pic.jpg');
        expect(result.ecoPoints, 150);
        expect(result.createdAt, tCreatedAt);
        expect(result.updatedAt, tUpdatedAt);
      });

      test('should handle null optional fields', () {
        final jsonWithNulls = {
          'id': 'user-456',
          'full_name': 'Jane Smith',
          'email': 'jane@example.com',
          'role': 'buyer',
          'phone_number': null,
          'profile_picture_url': null,
          'eco_points': 0,
          'created_at': '2024-03-01T08:00:00.000',
          'updated_at': null,
        };

        final result = UserModel.fromJson(jsonWithNulls);

        expect(result.phoneNumber, isNull);
        expect(result.profilePictureUrl, isNull);
        expect(result.updatedAt, isNull);
      });

      test('should handle missing optional fields', () {
        final jsonMissingOptionals = {
          'id': 'user-789',
          'full_name': 'Bob Builder',
          'email': 'bob@example.com',
          'role': 'collector',
          'created_at': '2024-03-01T08:00:00.000',
        };

        final result = UserModel.fromJson(jsonMissingOptionals);

        expect(result.phoneNumber, isNull);
        expect(result.profilePictureUrl, isNull);
        expect(result.ecoPoints, 0);
        expect(result.updatedAt, isNull);
      });

      test('should parse normalUser role correctly', () {
        final json = {
          ...tJsonMap,
          'role': 'normal_user',
        };

        final result = UserModel.fromJson(json);
        expect(result.role, UserRole.normalUser);
      });

      test('should parse buyer role correctly', () {
        final json = {
          ...tJsonMap,
          'role': 'buyer',
        };

        final result = UserModel.fromJson(json);
        expect(result.role, UserRole.buyer);
      });

      test('should parse collector role correctly', () {
        final json = {
          ...tJsonMap,
          'role': 'collector',
        };

        final result = UserModel.fromJson(json);
        expect(result.role, UserRole.collector);
      });

      test('should throw FormatException for invalid role', () {
        final json = {
          ...tJsonMap,
          'role': 'invalid_role',
        };

        expect(
          () => UserModel.fromJson(json),
          throwsA(isA<FormatException>()),
        );
      });

      test('should default ecoPoints to 0 when missing from JSON', () {
        final json = Map<String, dynamic>.from(tJsonMap)..remove('eco_points');

        final result = UserModel.fromJson(json);
        expect(result.ecoPoints, 0);
      });
    });

    group('toJson', () {
      test('should return a JSON map with all fields in snake_case', () {
        final result = tUserModel.toJson();

        expect(result['id'], 'user-123');
        expect(result['full_name'], 'John Doe');
        expect(result['email'], 'john@example.com');
        expect(result['role'], 'normal_user');
        expect(result['phone_number'], '+201234567890');
        expect(result['profile_picture_url'], 'https://example.com/pic.jpg');
        expect(result['eco_points'], 150);
        expect(result['created_at'], '2024-01-15T10:30:00.000');
        expect(result['updated_at'], '2024-02-20T14:45:00.000');
      });

      test('should include null values for optional fields when null', () {
        final userWithNulls = UserModel(
          id: 'user-456',
          fullName: 'Jane Smith',
          email: 'jane@example.com',
          role: UserRole.buyer,
          createdAt: tCreatedAt,
        );

        final result = userWithNulls.toJson();

        expect(result['phone_number'], isNull);
        expect(result['profile_picture_url'], isNull);
        expect(result['updated_at'], isNull);
      });

      test('should serialize buyer role correctly', () {
        final buyerModel = UserModel(
          id: 'user-1',
          fullName: 'Buyer User',
          email: 'buyer@example.com',
          role: UserRole.buyer,
          createdAt: tCreatedAt,
        );

        expect(buyerModel.toJson()['role'], 'buyer');
      });

      test('should serialize collector role correctly', () {
        final collectorModel = UserModel(
          id: 'user-2',
          fullName: 'Collector User',
          email: 'collector@example.com',
          role: UserRole.collector,
          createdAt: tCreatedAt,
        );

        expect(collectorModel.toJson()['role'], 'collector');
      });
    });

    group('fromJson -> toJson roundtrip', () {
      test('should produce equivalent JSON after roundtrip', () {
        final result = UserModel.fromJson(tJsonMap).toJson();

        expect(result['id'], tJsonMap['id']);
        expect(result['full_name'], tJsonMap['full_name']);
        expect(result['email'], tJsonMap['email']);
        expect(result['role'], tJsonMap['role']);
        expect(result['phone_number'], tJsonMap['phone_number']);
        expect(result['profile_picture_url'], tJsonMap['profile_picture_url']);
        expect(result['eco_points'], tJsonMap['eco_points']);
      });
    });

    group('fromEntity', () {
      test('should create UserModel from User entity', () {
        final user = User(
          id: 'user-999',
          fullName: 'Entity User',
          email: 'entity@example.com',
          role: UserRole.collector,
          phoneNumber: '+201111111111',
          ecoPoints: 500,
          createdAt: tCreatedAt,
        );

        final result = UserModel.fromEntity(user);

        expect(result.id, user.id);
        expect(result.fullName, user.fullName);
        expect(result.email, user.email);
        expect(result.role, user.role);
        expect(result.phoneNumber, user.phoneNumber);
        expect(result.ecoPoints, user.ecoPoints);
        expect(result.createdAt, user.createdAt);
      });
    });
  });
}
