import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:felo_na/core/errors/exceptions.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:felo_na/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:felo_na/features/auth/data/models/user_model.dart';
import 'package:felo_na/features/auth/domain/entities/user.dart';
import 'package:felo_na/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of [AuthRepository] that coordinates between remote and local data sources.
///
/// This class implements the repository pattern from Clean Architecture:
/// - Transforms exceptions from data sources into [Failure] types (Left values)
/// - On successful login/register: saves token and user to local storage
/// - On logout: clears all local data
/// - For getCurrentUser: tries local cache first, then remote
/// - Returns [Either<Failure, T>] for all operations
///
/// Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 3.1, 3.2, 3.3
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  /// Creates an [AuthRepositoryImpl] instance.
  ///
  /// [remoteDataSource] handles API communication for auth operations.
  /// [localDataSource] handles local token and user data persistence.
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final authResponse = await _remoteDataSource.registerWithToken(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
      );

      // Save token and user to local storage
      await _localDataSource.saveToken(authResponse.token);
      await _localDataSource.saveUser(authResponse.user);

      return Right(authResponse.user);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.fieldErrors, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode, e.code));
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await _remoteDataSource.loginWithToken(
        email: email,
        password: password,
      );

      // Save token and user to local storage
      await _localDataSource.saveToken(authResponse.token);
      await _localDataSource.saveUser(authResponse.user);

      return Right(authResponse.user);
    } on AuthenticationException catch (e) {
      return Left(AuthFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode, e.code));
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
  }) async {
    try {
      final updatedUser = await _remoteDataSource.updateProfile(
        userId: userId,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );

      // Update cached user data
      await _localDataSource.saveUser(updatedUser);

      return Right(updatedUser);
    } on AuthenticationException catch (e) {
      return Left(AuthFailure(e.message, e.code));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.fieldErrors, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode, e.code));
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final imageUrl = await _remoteDataSource.uploadProfilePicture(
        userId: userId,
        imageFile: imageFile,
      );

      return Right(imageUrl);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.fieldErrors, e.code));
    } on AuthenticationException catch (e) {
      return Left(AuthFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode, e.code));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Clear all local authentication data
      await _localDataSource.clearAll();
      return const Right(null);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message, e.code));
    } catch (e) {
      return Left(StorageFailure('Failed to clear local data: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // First check if we have a stored token
      final token = await _localDataSource.getToken();
      if (token == null) {
        return const Right(null);
      }

      // Try local cache first
      final cachedUser = await _localDataSource.getUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }

      // If no cached user but token exists, fetch from remote
      try {
        final remoteUser = await _remoteDataSource.getCurrentUser();
        // Cache the fetched user
        await _localDataSource.saveUser(remoteUser);
        return Right(remoteUser);
      } on AuthenticationException catch (e) {
        // Token is expired or invalid - clear local data
        await _localDataSource.clearAll();
        return Left(AuthFailure(e.message, e.code));
      } on NetworkException catch (e) {
        // Network error - return null since we can't verify the user
        return Left(NetworkFailure(e.message, e.code));
      }
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode, e.code));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
