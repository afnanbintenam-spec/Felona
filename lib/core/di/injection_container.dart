import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import '../network/secure_storage_service.dart';
import '../services/gemini_service.dart';
import '../services/image_upload_service.dart';
import '../services/push_notification_service.dart';

// AI
import '../../features/ai/data/datasources/ai_remote_data_source.dart';
import '../../features/ai/data/repositories/ai_repository_impl.dart';
import '../../features/ai/domain/repositories/ai_repository.dart';
import '../../features/ai/domain/usecases/scan_waste_usecase.dart';
import '../../features/ai/domain/usecases/chat_usecase.dart';
import '../../features/ai/presentation/bloc/ai_bloc.dart';

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

// Messaging
import '../../features/messaging/data/datasources/messaging_remote_data_source.dart';
import '../../features/messaging/data/repositories/messaging_repository_impl.dart';
import '../../features/messaging/domain/repositories/messaging_repository.dart';
import '../../features/messaging/presentation/bloc/messaging_bloc.dart';

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
      webOptions: WebOptions(
        dbName: 'felona_auth',
        publicKey: 'felona_public_key',
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

  // Gemini AI Service
  sl.registerLazySingleton<GeminiService>(() => GeminiService());

  // ========================================================================
  // Feature Dependencies
  // ========================================================================
  _initAiDependencies();
  _initMarketplaceDependencies();
  _initPickupDependencies();
  _initEcoScoreDependencies();
  _initNotificationDependencies();
  _initMessagingDependencies();
}

// ========================================================================
// AI
// ========================================================================
void _initAiDependencies() {
  // Data source
  sl.registerLazySingleton<AiRemoteDataSource>(
    () => AiRemoteDataSourceImpl(
      apiClient: sl<ApiClient>(),
      geminiService: sl<GeminiService>(),
    ),
  );

  // Repository
  sl.registerLazySingleton<AiRepository>(
    () => AiRepositoryImpl(remoteDataSource: sl<AiRemoteDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton<ScanWasteUseCase>(
    () => ScanWasteUseCase(sl<AiRepository>()),
  );
  sl.registerLazySingleton<ChatUseCase>(
    () => ChatUseCase(sl<AiRepository>()),
  );

  // BLoC
  sl.registerFactory<AiBloc>(
    () => AiBloc(
      scanWasteUseCase: sl<ScanWasteUseCase>(),
      chatUseCase: sl<ChatUseCase>(),
      repository: sl<AiRepository>(),
    ),
  );
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

// ========================================================================
// Messaging
// ========================================================================
void _initMessagingDependencies() {
  // Data source
  sl.registerLazySingleton<MessagingRemoteDataSource>(
    () => MessagingRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<MessagingRepository>(
    () => MessagingRepositoryImpl(remoteDataSource: sl<MessagingRemoteDataSource>()),
  );

  // BLoC — singleton so conversations stay loaded across tab switches
  sl.registerLazySingleton<MessagingBloc>(
    () => MessagingBloc(repository: sl<MessagingRepository>()),
  );
}
