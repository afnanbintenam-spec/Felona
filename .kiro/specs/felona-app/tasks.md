# Implementation Plan: FeloNa Mobile Application

## Overview

This implementation plan breaks down the FeloNa Flutter mobile application into discrete coding tasks following Clean Architecture principles with BLoC state management. The app connects three user roles (Normal Users, Buyers, Collectors) in a circular-economy ecosystem. Implementation follows a layered approach: Core infrastructure → Domain layer → Data layer → Presentation layer → Integration.

## Tasks

- [x] 1. Set up project structure and core infrastructure
  - [x] 1.1 Create Clean Architecture folder structure
    - Create `lib/core/` with subdirectories: `constants/`, `errors/`, `network/`, `utils/`
    - Create `lib/features/` with subdirectories: `auth/`, `marketplace/`, `pickup/`, `eco_score/`, `notifications/`
    - For each feature, create: `data/datasources/`, `data/models/`, `data/repositories/`, `domain/entities/`, `domain/repositories/`, `domain/usecases/`, `presentation/bloc/`, `presentation/pages/`, `presentation/widgets/`
    - _Requirements: All requirements (project foundation)_

  - [x] 1.2 Configure dependencies in pubspec.yaml
    - Add dependencies: `flutter_bloc`, `equatable`, `dartz`, `dio`, `flutter_secure_storage`, `get_it`, `firebase_core`, `firebase_messaging`, `image_picker`, `cached_network_image`, `intl`
    - Add dev dependencies: `mockito`, `bloc_test`, `build_runner`, `mockito_annotations`
    - _Requirements: All requirements (dependency management)_

  - [x] 1.3 Implement core error handling classes
    - Create `lib/core/errors/exceptions.dart` with exception hierarchy: `AppException`, `NetworkException`, `AuthenticationException`, `ValidationException`, `AuthorizationException`, `ServerException`, `StorageException`
    - Create `lib/core/errors/failures.dart` with failure classes: `Failure`, `NetworkFailure`, `AuthFailure`, `ValidationFailure`, `ServerFailure`
    - _Requirements: All requirements (error handling foundation)_

  - [x] 1.4 Implement Dio API client with interceptors
    - Create `lib/core/network/api_client.dart` with Dio configuration
    - Implement `AuthInterceptor` to inject JWT tokens into request headers
    - Implement `LoggingInterceptor` for request/response logging
    - Implement `ErrorInterceptor` to transform HTTP errors into domain exceptions
    - _Requirements: All requirements (network foundation)_

  - [x] 1.5 Implement secure storage service
    - Create `lib/core/network/secure_storage_service.dart` interface
    - Implement `SecureStorageServiceImpl` wrapping `flutter_secure_storage`
    - Add methods: `write()`, `read()`, `delete()`, `deleteAll()`
    - _Requirements: 1.4, 2.1, 2.3 (JWT and credential storage)_

  - [x] 1.6 Set up dependency injection with GetIt
    - Create `lib/core/di/injection_container.dart`
    - Register core services: `ApiClient`, `SecureStorageService`
    - Set up service locator initialization
    - _Requirements: All requirements (dependency management)_

- [x] 2. Checkpoint - Verify core infrastructure
  - Core infrastructure verified and working


- [x] 3. Implement Authentication domain layer (COMPLETED)
  - [x] 3.1 Create User entity and enumerations
    - Created `lib/features/auth/domain/entities/user.dart` with User entity
    - Created `lib/core/constants/enums.dart` with all enumerations including UserRole
    - _Requirements: 1.1, 1.5, 2.1, 3.1_

  - [x] 3.2 Create AuthRepository interface
    - Create `lib/features/auth/domain/repositories/auth_repository.dart`
    - Define methods: `register()`, `login()`, `updateProfile()`, `uploadProfilePicture()`, `logout()`, `getCurrentUser()`
    - Use `Either<Failure, T>` return types
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 3.1, 3.2, 3.3_

  - [x] 3.3 Implement authentication use cases
    - Create `RegisterUseCase` in `lib/features/auth/domain/usecases/register_usecase.dart`
    - Create `LoginUseCase` in `lib/features/auth/domain/usecases/login_usecase.dart`
    - Create `UpdateProfileUseCase` in `lib/features/auth/domain/usecases/update_profile_usecase.dart`
    - Create `UploadProfilePictureUseCase` in `lib/features/auth/domain/usecases/upload_profile_picture_usecase.dart`
    - Create `LogoutUseCase` in `lib/features/auth/domain/usecases/logout_usecase.dart`
    - Create `GetCurrentUserUseCase` in `lib/features/auth/domain/usecases/get_current_user_usecase.dart`
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 3.1, 3.2, 3.3_

  - [x] 3.4 Write unit tests for authentication use cases
    - Test successful registration, login, profile update, logout flows
    - Test validation errors (password length, email format)
    - Test authentication failures
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 3.1, 3.2, 3.3_

- [x] 4. Implement Authentication data layer
  - [x] 4.1 Create UserModel with JSON serialization
    - Create `lib/features/auth/data/models/user_model.dart` extending User entity
    - Implement `fromJson()` and `toJson()` methods
    - Handle snake_case to camelCase conversion
    - _Requirements: 1.1, 1.5, 2.1, 3.1_

  - [x] 4.2 Implement AuthRemoteDataSource
    - Create `lib/features/auth/data/datasources/auth_remote_datasource.dart`
    - Implement API calls: `register()`, `login()`, `updateProfile()`, `uploadProfilePicture()`
    - Use Dio for HTTP requests with multipart support for image uploads
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 3.1, 3.2, 3.3_

  - [x] 4.3 Implement AuthLocalDataSource
    - Create `lib/features/auth/data/datasources/auth_local_datasource.dart`
    - Implement JWT token storage and retrieval using SecureStorageService
    - Implement user data caching
    - _Requirements: 1.4, 2.1, 2.3_

  - [x] 4.4 Implement AuthRepositoryImpl
    - Create `lib/features/auth/data/repositories/auth_repository_impl.dart`
    - Implement all AuthRepository interface methods
    - Handle error transformation from exceptions to failures
    - Coordinate between remote and local data sources
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 3.1, 3.2, 3.3_

  - [ ]* 4.5 Write unit tests for authentication data layer
    - Test UserModel JSON serialization/deserialization
    - Test AuthRemoteDataSource API calls with mocked Dio
    - Test AuthLocalDataSource storage operations
    - Test AuthRepositoryImpl error handling and data coordination
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 3.1, 3.2, 3.3_

- [x] 5. Implement Authentication presentation layer (PARTIALLY COMPLETED)
  - [x] 5.1 Create AuthBloc with events and states
    - Created `lib/features/auth/presentation/bloc/auth_bloc.dart`
    - Defined events: `LoginRequested`, `RegisterRequested`, `LogoutRequested`, `UpdateProfileRequested`, `UploadProfilePictureRequested`
    - Defined states: `AuthInitial`, `AuthLoading`, `Authenticated`, `Unauthenticated`, `AuthError`, `ProfileUpdated`
    - Implemented event handlers with mock data
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 3.1, 3.2, 3.3_

  - [x] 5.2 Create registration screen UI
    - Created `lib/features/auth/presentation/pages/register_screen.dart`
    - Implemented form with fields: full name, email, password, role selection
    - Added client-side validation (password ≥8 chars, email format)
    - Display role selection with three interactive cards
    - Wired up to AuthBloc
    - _Requirements: 1.1, 1.2, 1.3, 1.5_

  - [x] 5.3 Create login screen UI
    - Created `lib/features/auth/presentation/pages/login_screen.dart`
    - Implemented form with email and password fields
    - Added loading indicator during authentication
    - Display error messages via SnackBar
    - Wired up to AuthBloc
    - _Requirements: 2.1, 2.2, 2.3_

  - [x] 5.4 Create profile screen UI
    - Create `lib/features/auth/presentation/pages/profile_screen.dart`
    - Display user profile: picture, name, email, role, phone number
    - Implement profile editing form
    - Add image picker for profile picture upload with validation (JPEG/PNG, max 5MB)
    - Wire up to AuthBloc
    - _Requirements: 3.1, 3.2, 3.3_

  - [ ]* 5.5 Write widget tests for authentication screens
    - Test registration screen form validation and submission
    - Test login screen user interactions
    - Test profile screen display and editing
    - Test error state rendering
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.2, 2.3, 3.1, 3.2, 3.3_

  - [ ]* 5.6 Write BLoC tests for AuthBloc
    - Test state transitions for login, registration, logout
    - Test error handling for invalid credentials
    - Test profile update flows
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 3.1, 3.2, 3.3_

- [x] 6. Checkpoint - Verify authentication feature
  - Ensure all tests pass, ask the user if questions arise.

