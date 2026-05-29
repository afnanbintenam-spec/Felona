import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import '../network/secure_storage_service.dart';
import '../services/image_upload_service.dart';
import '../services/push_notification_service.dart';

// Marketplace
import '../../features/marketplace/data/datasources/marketplace_remote_data_source.dart';
import '../../features/marketplace/data/repositories/marketplace_repository_impl.dart';
import '../../features/marketplace/domain/repositories/marketplace_repository.dart';
import '../../features/marketplace/presentation/bloc/marketplace_bloc.dart';

// Pickup
import '../../features/pickup/data/datasources/pickup_remote_data_source.dart';
import '../../features/pickup/data/repositories/pickup_repository_impl.dart';
import '../../features/pickup/domain/repositories/pickup_repository.dart';
import '../../features/pickup/presentation/bloc/pickup_bloc.dart';

// Eco Score
import '../../features/eco_score/data/datasources/eco_remote_data_source.dart';
import '../../features/eco_score/data/repositories/eco_repository_impl.dart';
import '../../features/eco_score/domain/repositories/eco_repository.dart';
import '../../features/eco_score/presentation/bloc/eco_bloc.dart';

// Notifications
import '../../features/notifications/data/datasources/notifications_remote_data_source.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Initializes all dependencies and registers them with the service locator.
Future<void> initializeDependencies() async {
  // ========================================================================
  // Core Services
  // ========================================================================

  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    ),
  );

  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageServiceImpl(
      storage: sl<FlutterSecureStorage>(),
    ),
  );

  sl.registerLazySingleton<Dio>(() => Dio());

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      secureStorage: sl<FlutterSecureStorage>(),
      dio: sl<Dio>(),
    ),
  );

  // Image Upload Service
  sl.registerLazySingleton<ImageUploadService>(
    () => ImageUploadService(apiClient: sl<ApiClient>()),
  );

  // Push Notification Service
  sl.registerLazySingleton<PushNotificationService>(
    () => PushNotificationService(),
  );

  // ========================================================================
  // Feature Dependencies
  // ========================================================================
  _initMarketplaceDependencies();
  _initPickupDependencies();
  _initEcoScoreDependencies();
  _initNotificationDependencies();
}

// ========================================================================
// Marketplace
// ========================================================================
void _initMarketplaceDependencies() {
  // Data source
  sl.registerLazySingleton<MarketplaceRemoteDataSource>(
    () => MarketplaceRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<MarketplaceRepository>(
    () => MarketplaceRepositoryImpl(remoteDataSource: sl<MarketplaceRemoteDataSource>()),
  );

  // BLoC
  sl.registerFactory<MarketplaceBloc>(
    () => MarketplaceBloc(repository: sl<MarketplaceRepository>()),
  );
}

// ========================================================================
// Pickup
// ========================================================================
void _initPickupDependencies() {
  // Data source
  sl.registerLazySingleton<PickupRemoteDataSource>(
    () => PickupRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<PickupRepository>(
    () => PickupRepositoryImpl(remoteDataSource: sl<PickupRemoteDataSource>()),
  );

  // BLoC
  sl.registerFactory<PickupBloc>(
    () => PickupBloc(repository: sl<PickupRepository>()),
  );
}

// ========================================================================
// Eco Score
// ========================================================================
void _initEcoScoreDependencies() {
  // Data source
  sl.registerLazySingleton<EcoRemoteDataSource>(
    () => EcoRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<EcoRepository>(
    () => EcoRepositoryImpl(remoteDataSource: sl<EcoRemoteDataSource>()),
  );

  // BLoC
  sl.registerFactory<EcoBloc>(
    () => EcoBloc(repository: sl<EcoRepository>()),
  );
}

// ========================================================================
// Notifications
// ========================================================================
void _initNotificationDependencies() {
  // Data source
  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(remoteDataSource: sl<NotificationsRemoteDataSource>()),
  );

  // BLoC
  sl.registerFactory<NotificationsBloc>(
    () => NotificationsBloc(repository: sl<NotificationsRepository>()),
  );
}
