import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import '../network/secure_storage_service.dart';

/// Global service locator instance.
///
/// Provides access to registered dependencies throughout the application.
/// Use `sl<Type>()` to retrieve registered instances.
final sl = GetIt.instance;

/// Initializes all dependencies and registers them with the service locator.
///
/// This function should be called once at app startup, before runApp().
/// It sets up the dependency injection container with all required services.
///
/// Example:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await initializeDependencies();
///   runApp(MyApp());
/// }
/// ```
Future<void> initializeDependencies() async {
  // ========================================================================
  // Core Services
  // ========================================================================

  // Register FlutterSecureStorage as a singleton
  // This is the underlying storage mechanism used by SecureStorageService
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    ),
  );

  // Register SecureStorageService as a singleton
  // Provides secure storage for JWT tokens and sensitive data
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageServiceImpl(
      storage: sl<FlutterSecureStorage>(),
    ),
  );

  // Register Dio as a singleton
  // HTTP client used by ApiClient
  sl.registerLazySingleton<Dio>(() => Dio());

  // Register ApiClient as a singleton
  // Centralized HTTP client with interceptors for auth, logging, and error handling
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      secureStorage: sl<FlutterSecureStorage>(),
      dio: sl<Dio>(),
    ),
  );

  // ========================================================================
  // Feature Dependencies
  // ========================================================================
  // TODO: Register feature-specific dependencies (repositories, use cases, BLoCs)
  // as they are implemented in subsequent tasks.
  //
  // Example structure:
  // _initAuthDependencies();
  // _initMarketplaceDependencies();
  // _initPickupDependencies();
  // _initEcoScoreDependencies();
  // _initNotificationDependencies();
}

// ========================================================================
// Feature-specific dependency initialization functions
// ========================================================================
// These will be implemented as features are developed

/// Initializes authentication feature dependencies.
///
/// Registers:
/// - AuthRemoteDataSource
/// - AuthLocalDataSource
/// - AuthRepository
/// - Authentication use cases
/// - AuthBloc
// void _initAuthDependencies() {
//   // Data sources
//   sl.registerLazySingleton<AuthRemoteDataSource>(
//     () => AuthRemoteDataSourceImpl(apiClient: sl()),
//   );
//
//   sl.registerLazySingleton<AuthLocalDataSource>(
//     () => AuthLocalDataSourceImpl(secureStorage: sl()),
//   );
//
//   // Repository
//   sl.registerLazySingleton<AuthRepository>(
//     () => AuthRepositoryImpl(
//       remoteDataSource: sl(),
//       localDataSource: sl(),
//     ),
//   );
//
//   // Use cases
//   sl.registerLazySingleton(() => RegisterUseCase(sl()));
//   sl.registerLazySingleton(() => LoginUseCase(sl()));
//   sl.registerLazySingleton(() => LogoutUseCase(sl()));
//   sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
//   sl.registerLazySingleton(() => UploadProfilePictureUseCase(sl()));
//   sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
//
//   // BLoC
//   sl.registerFactory(
//     () => AuthBloc(
//       registerUseCase: sl(),
//       loginUseCase: sl(),
//       logoutUseCase: sl(),
//       updateProfileUseCase: sl(),
//       uploadProfilePictureUseCase: sl(),
//       getCurrentUserUseCase: sl(),
//     ),
//   );
// }

/// Initializes marketplace feature dependencies.
// void _initMarketplaceDependencies() {
//   // TODO: Implement when marketplace feature is developed
// }

/// Initializes pickup feature dependencies.
// void _initPickupDependencies() {
//   // TODO: Implement when pickup feature is developed
// }

/// Initializes eco score feature dependencies.
// void _initEcoScoreDependencies() {
//   // TODO: Implement when eco score feature is developed
// }

/// Initializes notification feature dependencies.
// void _initNotificationDependencies() {
//   // TODO: Implement when notification feature is developed
// }
