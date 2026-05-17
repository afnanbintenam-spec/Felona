// Manually written mocks for auth use case tests.
// These mocks implement the interfaces needed for testing with proper
// default return values for mockito compatibility.

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/entities/user.dart';
import 'package:felo_na/features/auth/domain/repositories/auth_repository.dart';

final _defaultUser = User(
  id: '',
  fullName: '',
  email: '',
  role: UserRole.normalUser,
  createdAt: DateTime(2024),
);

// ignore: must_be_immutable
class MockAuthRepository extends Mock implements AuthRepository {
  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) =>
      super.noSuchMethod(
        Invocation.method(#register, [], {
          #email: email,
          #password: password,
          #fullName: fullName,
          #role: role,
        }),
        returnValue: Future.value(Right<Failure, User>(_defaultUser)),
      ) as Future<Either<Failure, User>>;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) =>
      super.noSuchMethod(
        Invocation.method(#login, [], {
          #email: email,
          #password: password,
        }),
        returnValue: Future.value(Right<Failure, User>(_defaultUser)),
      ) as Future<Either<Failure, User>>;

  @override
  Future<Either<Failure, User>> updateProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
  }) =>
      super.noSuchMethod(
        Invocation.method(#updateProfile, [], {
          #userId: userId,
          #fullName: fullName,
          #phoneNumber: phoneNumber,
        }),
        returnValue: Future.value(Right<Failure, User>(_defaultUser)),
      ) as Future<Either<Failure, User>>;

  @override
  Future<Either<Failure, String>> uploadProfilePicture({
    required String userId,
    required File imageFile,
  }) =>
      super.noSuchMethod(
        Invocation.method(#uploadProfilePicture, [], {
          #userId: userId,
          #imageFile: imageFile,
        }),
        returnValue: Future.value(const Right<Failure, String>('')),
      ) as Future<Either<Failure, String>>;

  @override
  Future<Either<Failure, void>> logout() => super.noSuchMethod(
        Invocation.method(#logout, []),
        returnValue: Future.value(const Right<Failure, void>(null)),
      ) as Future<Either<Failure, void>>;

  @override
  Future<Either<Failure, User?>> getCurrentUser() => super.noSuchMethod(
        Invocation.method(#getCurrentUser, []),
        returnValue: Future.value(const Right<Failure, User?>(null)),
      ) as Future<Either<Failure, User?>>;
}

class MockFile extends Mock implements File {}
