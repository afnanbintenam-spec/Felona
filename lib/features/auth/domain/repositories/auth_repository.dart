import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/entities/user.dart';

/// Repository interface for authentication operations.
///
/// This abstract class defines the contract for authentication-related
/// data operations. It follows the Repository pattern from Clean Architecture,
/// abstracting data sources from business logic.
///
/// All methods return Either<Failure, T> to handle errors functionally:
/// - Left(Failure): Operation failed with a specific failure type
/// - Right(T): Operation succeeded with the result
///
/// Implementations should:
/// - Transform exceptions into appropriate Failure types
/// - Handle both remote (API) and local (storage) data sources
/// - Manage JWT token persistence
/// - Coordinate authentication state
abstract class AuthRepository {
  /// Registers a new user account.
  ///
  /// Creates a new user with the provided credentials and role selection.
  /// On success, stores the JWT token and returns the created user.
  ///
  /// Parameters:
  /// - [email]: User's email address (must be unique)
  /// - [password]: User's password (must be at least 8 characters)
  /// - [fullName]: User's full name
  /// - [role]: Selected user role (Normal_User, Buyer, or Collector)
  ///
  /// Returns:
  /// - Right(User): Registration successful, JWT stored
  /// - Left(ValidationFailure): Invalid input (email exists, password too short)
  /// - Left(NetworkFailure): Network connection error
  /// - Left(ServerFailure): Server-side error
  ///
  /// Requirements: 1.1, 1.2, 1.3, 1.4, 1.5
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
  });

  /// Authenticates a user with email and password.
  ///
  /// Validates credentials and returns a JWT token valid for 30 days.
  /// On success, stores the JWT token securely.
  ///
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  ///
  /// Returns:
  /// - Right(User): Login successful, JWT stored
  /// - Left(AuthFailure): Invalid credentials (email or password incorrect)
  /// - Left(NetworkFailure): Network connection error
  /// - Left(ServerFailure): Server-side error
  ///
  /// Requirements: 2.1, 2.2
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Updates the authenticated user's profile information.
  ///
  /// Allows updating full name and phone number. Email and role cannot be changed.
  ///
  /// Parameters:
  /// - [userId]: ID of the user to update
  /// - [fullName]: New full name (optional)
  /// - [phoneNumber]: New phone number (optional)
  ///
  /// Returns:
  /// - Right(User): Profile updated successfully
  /// - Left(AuthFailure): User not authenticated
  /// - Left(ValidationFailure): Invalid input data
  /// - Left(NetworkFailure): Network connection error
  /// - Left(ServerFailure): Server-side error
  ///
  /// Requirements: 3.1
  Future<Either<Failure, User>> updateProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
  });

  /// Uploads a profile picture for the authenticated user.
  ///
  /// Accepts JPEG or PNG images with a maximum size of 5 MB.
  /// Returns the URL of the uploaded image.
  ///
  /// Parameters:
  /// - [userId]: ID of the user
  /// - [imageFile]: Image file to upload
  ///
  /// Returns:
  /// - Right(String): Upload successful, returns image URL
  /// - Left(ValidationFailure): Invalid file (wrong format or exceeds 5 MB)
  /// - Left(AuthFailure): User not authenticated
  /// - Left(NetworkFailure): Network connection error
  /// - Left(ServerFailure): Server-side error
  ///
  /// Requirements: 3.2, 3.3
  Future<Either<Failure, String>> uploadProfilePicture({
    required String userId,
    required File imageFile,
  });

  /// Logs out the current user.
  ///
  /// Clears the stored JWT token and any cached user data.
  /// This operation always succeeds locally, even if the server
  /// cannot be reached to invalidate the token.
  ///
  /// Returns:
  /// - Right(void): Logout successful
  /// - Left(StorageFailure): Failed to clear local storage (rare)
  ///
  /// Requirements: 2.3
  Future<Either<Failure, void>> logout();

  /// Retrieves the currently authenticated user.
  ///
  /// Checks for a valid JWT token and returns the associated user data.
  /// Returns null if no user is authenticated or the token has expired.
  ///
  /// Returns:
  /// - Right(User): User is authenticated
  /// - Right(null): No authenticated user
  /// - Left(StorageFailure): Failed to read from storage
  /// - Left(NetworkFailure): Failed to fetch user data
  /// - Left(AuthFailure): Token expired or invalid
  ///
  /// Requirements: 2.3
  Future<Either<Failure, User?>> getCurrentUser();
}
