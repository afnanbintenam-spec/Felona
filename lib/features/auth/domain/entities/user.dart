import 'package:equatable/equatable.dart';
import 'package:felo_na/core/constants/enums.dart';

/// User entity representing a user in the system.
///
/// This is a domain entity that contains the core user data
/// without any framework-specific dependencies.
class User extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final int ecoPoints;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.profilePictureUrl,
    this.ecoPoints = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a copy of this user with the given fields replaced with new values.
  User copyWith({
    String? id,
    String? fullName,
    String? email,
    UserRole? role,
    String? phoneNumber,
    String? profilePictureUrl,
    int? ecoPoints,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      ecoPoints: ecoPoints ?? this.ecoPoints,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        role,
        phoneNumber,
        profilePictureUrl,
        ecoPoints,
        createdAt,
        updatedAt,
      ];
}
