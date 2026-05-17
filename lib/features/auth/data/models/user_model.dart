import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/features/auth/domain/entities/user.dart';

/// Data model for User that extends the domain entity with JSON serialization.
///
/// This model handles the conversion between the API's snake_case JSON format
/// and the domain entity's camelCase properties.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.role,
    super.phoneNumber,
    super.profilePictureUrl,
    super.ecoPoints,
    required super.createdAt,
    super.updatedAt,
  });

  /// Creates a [UserModel] from a JSON map returned by the API.
  ///
  /// Handles snake_case to camelCase field mapping:
  /// - `full_name` -> `fullName`
  /// - `phone_number` -> `phoneNumber`
  /// - `profile_picture_url` -> `profilePictureUrl`
  /// - `eco_points` -> `ecoPoints`
  /// - `created_at` -> `createdAt`
  /// - `updated_at` -> `updatedAt`
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      role: _parseUserRole(json['role'] as String),
      phoneNumber: json['phone_number'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      ecoPoints: (json['eco_points'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts this [UserModel] to a JSON map for API requests.
  ///
  /// Uses snake_case keys to match the API's expected format.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': _roleToString(role),
      'phone_number': phoneNumber,
      'profile_picture_url': profilePictureUrl,
      'eco_points': ecoPoints,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a [UserModel] from an existing [User] entity.
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      role: user.role,
      phoneNumber: user.phoneNumber,
      profilePictureUrl: user.profilePictureUrl,
      ecoPoints: user.ecoPoints,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  /// Parses a role string from the API into a [UserRole] enum value.
  ///
  /// Accepts: 'normal_user', 'buyer', 'collector' (case-insensitive).
  static UserRole _parseUserRole(String value) {
    switch (value.toLowerCase()) {
      case 'normal_user':
        return UserRole.normalUser;
      case 'buyer':
        return UserRole.buyer;
      case 'collector':
        return UserRole.collector;
      default:
        throw FormatException('Invalid user role: $value');
    }
  }

  /// Converts a [UserRole] enum value to its API string representation.
  static String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.normalUser:
        return 'normal_user';
      case UserRole.buyer:
        return 'buyer';
      case UserRole.collector:
        return 'collector';
    }
  }
}
