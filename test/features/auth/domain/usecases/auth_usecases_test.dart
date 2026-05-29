import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/errors/failures.dart';
import 'package:felo_na/features/auth/domain/entities/user.dart';
import 'package:felo_na/features/auth/domain/repositories/auth_repository.dart';
import 'package:felo_na/features/auth/domain/usecases/usecase.dart';
import 'package:felo_na/features/auth/domain/usecases/register_usecase.dart';
import 'package:felo_na/features/auth/domain/usecases/login_usecase.dart';
import 'package:felo_na/features/auth/domain/usecases/logout_usecase.dart';
import 'package:felo_na/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:felo_na/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:felo_na/features/auth/domain/usecases/upload_profile_picture_usecase.dart';

import 'auth_usecases_test.mocks.dart';

@GenerateMocks([AuthRepository, File])

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockFile mockFile;

  // Test data
  final tUser = User(
    id: '1',
    fullName: 'Test User',
    email: 'test@example.com',
    role: UserRole.normalUser,
    phoneNumber: '+1234567890',
    profilePictureUrl: 'https://example.com/pic.jpg',
    ecoPoints: 0,
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockFile = MockFile();
  });

  group('RegisterUseCase', () {
    late RegisterUseCase useCase;

    setUp(() {
      useCase = RegisterUseCase(mockAuthRepository);
    });

    const tParams = RegisterParams(
      email: 'test@example.com',
      password: 'password123',
      fullName: 'Test User',
      role: 'normal_user',
    );

    test('should return User when registration is successful', () async {
      // Arrange
      when(mockAuthRepository.register(
        email: tParams.email,
        password: tParams.password,
        fullName: tParams.fullName,
        role: tParams.role,
      )).thenAnswer((_) async => Right(tUser));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, Right(tUser));
      verify(mockAuthRepository.register(
        email: tParams.email,
        password: tParams.password,
        fullName: tParams.fullName,
        role: tParams.role,
      )).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return ValidationFailure when email already exists', () async {
      // Arrange
      const tFailure = ValidationFailure(
        'Email already registered',
        {'email': 'Email already exists'},
      );
      when(mockAuthRepository.register(
        email: tParams.email,
        password: tParams.password,
        fullName: tParams.fullName,
        role: tParams.role,
      )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Left(tFailure));
      verify(mockAuthRepository.register(
        email: tParams.email,
        password: tParams.password,
        fullName: tParams.fullName,
        role: tParams.role,
      )).called(1);
    });

    test('should return ValidationFailure when password is too short',
        () async {
      // Arrange
      const shortPasswordParams = RegisterParams(
        email: 'test@example.com',
        password: 'short',
        fullName: 'Test User',
        role: 'normal_user',
      );
      const tFailure = ValidationFailure(
        'Password must be at least 8 characters',
        {'password': 'Password too short'},
      );
      when(mockAuthRepository.register(
        email: shortPasswordParams.email,
        password: shortPasswordParams.password,
        fullName: shortPasswordParams.fullName,
        role: shortPasswordParams.role,
      )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(shortPasswordParams);

      // Assert
      expect(result, const Left(tFailure));
    });

    test('should return NetworkFailure when there is no connection', () async {
      // Arrange
      const tFailure = NetworkFailure('No internet connection');
      when(mockAuthRepository.register(
        email: tParams.email,
        password: tParams.password,
        fullName: tParams.fullName,
        role: tParams.role,
      )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Left(tFailure));
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      const tFailure = ServerFailure('Internal server error', 500);
      when(mockAuthRepository.register(
        email: tParams.email,
        password: tParams.password,
        fullName: tParams.fullName,
        role: tParams.role,
      )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Left(tFailure));
    });

    test('RegisterParams should support value equality', () {
      // Arrange
      const params1 = RegisterParams(
        email: 'test@example.com',
        password: 'password123',
        fullName: 'Test User',
        role: 'normal_user',
      );
      const params2 = RegisterParams(
        email: 'test@example.com',
        password: 'password123',
        fullName: 'Test User',
        role: 'normal_user',
      );

      // Assert
      expect(params1, equals(params2));
    });
  });

  group('LoginUseCase', () {
    late LoginUseCase useCase;

    setUp(() {
      useCase = LoginUseCase(mockAuthRepository);
    });

    const tParams = LoginParams(
      email: 'test@example.com',
      password: 'password123',
    );

    test('should return User when login is successful', () async {
      // Arrange
      when(mockAuthRepository.login(
        email: tParams.email,
        password: tParams.password,
      )).thenAnswer((_) async => Right(tUser));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, Right(tUser));
      verify(mockAuthRepository.login(
        email: tParams.email,
        password: tParams.password,
      )).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return AuthFailure when credentials are invalid', () async {
      // Arrange
      const tFailure = AuthFailure('Invalid email or password');
      when(mockAuthRepository.login(
        email: tParams.email,
        password: tParams.password,
      )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Left(tFailure));
      verify(mockAuthRepository.login(
        email: tParams.email,
        password: tParams.password,
      )).called(1);
    });

    test('should return NetworkFailure when there is no connection', () async {
      // Arrange
      const tFailure = NetworkFailure('No internet connection');
      when(mockAuthRepository.login(
        email: tParams.email,
        password: tParams.password,
      )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Left(tFailure));
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      const tFailure = ServerFailure('Server unavailable', 503);
      when(mockAuthRepository.login(
        email: tParams.email,
        password: tParams.password,
      )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Left(tFailure));
    });

    test('LoginParams should support value equality', () {
      // Arrange
      const params1 = LoginParams(
        email: 'test@example.com',
        password: 'password123',
      );
      const params2 = LoginParams(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      expect(params1, equals(params2));
    });
  });

  group('LogoutUseCase', () {
    late LogoutUseCase useCase;

    setUp(() {
      useCase = LogoutUseCase(mockAuthRepository);
    });

    test('should return void when logout is successful', () async {
      // Arrange
      when(mockAuthRepository.logout())
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, const Right(null));
      verify(mockAuthRepository.logout()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return StorageFailure when clearing storage fails', () async {
      // Arrange
      const tFailure = StorageFailure('Failed to clear storage');
      when(mockAuthRepository.logout())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, const Left(tFailure));
      verify(mockAuthRepository.logout()).called(1);
    });
  });

  group('GetCurrentUserUseCase', () {
    late GetCurrentUserUseCase useCase;

    setUp(() {
      useCase = GetCurrentUserUseCase(mockAuthRepository);
    });

    test('should return User when user is authenticated', () async {
      // Arrange
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(tUser));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, Right(tUser));
      verify(mockAuthRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return null when no user is authenticated', () async {
      // Arrange
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, const Right(null));
      verify(mockAuthRepository.getCurrentUser()).called(1);
    });

    test('should return AuthFailure when token is expired', () async {
      // Arrange
      const tFailure = AuthFailure('Token expired');
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, const Left(tFailure));
    });

    test('should return StorageFailure when reading storage fails', () async {
      // Arrange
      const tFailure = StorageFailure('Failed to read from storage');
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, const Left(tFailure));
    });

    test('should return NetworkFailure when fetching user data fails',
        () async {
      // Arrange
      const tFailure = NetworkFailure('Network error');
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, const Left(tFailure));
    });
  });

  group('UpdateProfileUseCase', () {
    late UpdateProfileUseCase useCase;

    setUp(() {
      useCase = UpdateProfileUseCase(mockAuthRepository);
    });

    final tUpdatedUser = tUser.copyWith(
      fullName: 'Updated Name',
      phoneNumber: '+9876543210',
    );

    test('should return updated User when profile update is successful',
        () async {
      // Arrange
      const tParams = UpdateProfileParams(
        userId: '1',
        fullName: 'Updated Name',
        phoneNumber: '+9876543210',
      );
      when(mockAuthRepository.updateProfile(
        userId: tParams.userId,
        fullName: tParams.fullName,
        phoneNumber: tParams.phoneNumber,
      )).thenAnswer((_) async => Right(tUpdatedUser));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, Right(tUpdatedUser));
      verify(mockAuthRepository.updateProfile(
        userId: tParams.userId,
        fullName: tParams.fullName,
        phoneNumber: tParams.phoneNumber,
      )).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should update only fullName when phoneNumber is null', () async {
      // Arrange
      const tParams = UpdateProfileParams(
        userId: '1',
        fullName: 'Updated Name',
      );
      final expectedUser = tUser.copyWith(fullName: 'Updated Name');
      when(mockAuthRepository.updateProfile(
        userId: tParams.userId,
        fullName: tParams.fullName,
        phoneNumber: null,
      )).thenAnswer((_) async => Right(expectedUser));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, Right(expectedUser));
      verify(mockAuthRepository.updateProfile(
        userId: '1',
        fullName: 'Updated Name',
        phoneNumber: null,
      )).called(1);
    });

    test('should update only phoneNumber when fullName is null', () async {
      // Arrange
      const tParams = UpdateProfileParams(
        userId: '1',
        phoneNumber: '+9876543210',
      );
      final expectedUser = tUser.copyWith(phoneNumber: '+9876543210');
      when(mockAuthRepository.updateProfile(
        userId: tParams.userId,
        fullName: null,
        phoneNumber: tParams.phoneNumber,
      )).thenAnswer((_) async => Right(expectedUser));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, Right(expectedUser));
    });

    test('should return AuthFailure when user is not authenticated', () async {
      // Arrange
      const tParams = UpdateProfileParams(
        userId: '1',
        fullName: 'Updated Name',
      );
      const tFailure = AuthFailure('User not authenticated');
      when(mockAuthRepository.updateProfile(
        userId: tParams.userId,
        fullName: tParams.fullName,
        phoneNumber: null,
      )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Left(tFailure));
    });

    test('should return ValidationFailure when input is invalid', () async {
      // Arrange
      const tParams = UpdateProfileParams(
        userId: '1',
        fullName: '',
      );
      const tFailure = ValidationFailure(
        'Invalid input',
        {'full_name': 'Name cannot be empty'},
      );
      when(mockAuthRepository.updateProfile(
        userId: tParams.userId,
        fullName: tParams.fullName,
        phoneNumber: null,
      )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Left(tFailure));
    });

    test('should return NetworkFailure when there is no connection', () async {
      // Arrange
      const tParams = UpdateProfileParams(
        userId: '1',
        fullName: 'Updated Name',
      );
      const tFailure = NetworkFailure('No internet connection');
      when(mockAuthRepository.updateProfile(
        userId: tParams.userId,
        fullName: tParams.fullName,
        phoneNumber: null,
      )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Left(tFailure));
    });

    test('UpdateProfileParams should support value equality', () {
      // Arrange
      const params1 = UpdateProfileParams(
        userId: '1',
        fullName: 'Name',
        phoneNumber: '+123',
      );
      const params2 = UpdateProfileParams(
        userId: '1',
        fullName: 'Name',
        phoneNumber: '+123',
      );

      // Assert
      expect(params1, equals(params2));
    });
  });

  group('UploadProfilePictureUseCase', () {
    late UploadProfilePictureUseCase useCase;

    setUp(() {
      useCase = UploadProfilePictureUseCase(mockAuthRepository);
    });

    const tImageUrl = 'https://example.com/uploads/profile_pic.jpg';

    test('should return image URL when upload is successful', () async {
      // Arrange
      final tParams = UploadProfilePictureParams(
        userId: '1',
        imageFile: mockFile,
      );
      when(mockAuthRepository.uploadProfilePicture(
        userId: tParams.userId,
        imageFile: tParams.imageFile,
      )).thenAnswer((_) async => const Right(tImageUrl));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Right(tImageUrl));
      verify(mockAuthRepository.uploadProfilePicture(
        userId: tParams.userId,
        imageFile: tParams.imageFile,
      )).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return ValidationFailure when file exceeds 5 MB', () async {
      // Arrange
      final tParams = UploadProfilePictureParams(
        userId: '1',
        imageFile: mockFile,
      );
      const tFailure = ValidationFailure(
        'File size exceeds 5 MB limit',
        {'image': 'File too large'},
      );
      when(mockAuthRepository.uploadProfilePicture(
        userId: tParams.userId,
        imageFile: tParams.imageFile,
      )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Left(tFailure));
    });

    test('should return ValidationFailure when file format is invalid',
        () async {
      // Arrange
      final tParams = UploadProfilePictureParams(
        userId: '1',
        imageFile: mockFile,
      );
      const tFailure = ValidationFailure(
        'Invalid file format. Only JPEG and PNG are accepted.',
        {'image': 'Invalid format'},
      );
      when(mockAuthRepository.uploadProfilePicture(
        userId: tParams.userId,
        imageFile: tParams.imageFile,
      )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Left(tFailure));
    });

    test('should return AuthFailure when user is not authenticated', () async {
      // Arrange
      final tParams = UploadProfilePictureParams(
        userId: '1',
        imageFile: mockFile,
      );
      const tFailure = AuthFailure('User not authenticated');
      when(mockAuthRepository.uploadProfilePicture(
        userId: tParams.userId,
        imageFile: tParams.imageFile,
      )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Left(tFailure));
    });

    test('should return NetworkFailure when upload fails due to network',
        () async {
      // Arrange
      final tParams = UploadProfilePictureParams(
        userId: '1',
        imageFile: mockFile,
      );
      const tFailure = NetworkFailure('Upload failed: connection timeout');
      when(mockAuthRepository.uploadProfilePicture(
        userId: tParams.userId,
        imageFile: tParams.imageFile,
      )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Left(tFailure));
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      final tParams = UploadProfilePictureParams(
        userId: '1',
        imageFile: mockFile,
      );
      const tFailure = ServerFailure('Internal server error', 500);
      when(mockAuthRepository.uploadProfilePicture(
        userId: tParams.userId,
        imageFile: tParams.imageFile,
      )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, const Left(tFailure));
    });
  });

  group('NoParams', () {
    test('should support value equality', () {
      // Assert
      expect(const NoParams(), equals(const NoParams()));
    });
  });
}
