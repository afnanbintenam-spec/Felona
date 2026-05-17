import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:felo_na/core/di/injection_container.dart';
import 'package:felo_na/core/network/api_client.dart';
import 'package:felo_na/core/network/secure_storage_service.dart';

void main() {
  group('Dependency Injection Container', () {
    setUp(() async {
      // Reset GetIt before each test
      await sl.reset();
    });

    test('should initialize all core dependencies', () async {
      // Act
      await initializeDependencies();

      // Assert - Verify all core services are registered
      expect(sl.isRegistered<FlutterSecureStorage>(), true);
      expect(sl.isRegistered<SecureStorageService>(), true);
      expect(sl.isRegistered<Dio>(), true);
      expect(sl.isRegistered<ApiClient>(), true);
    });

    test('should return same instance for singleton services', () async {
      // Arrange
      await initializeDependencies();

      // Act
      final apiClient1 = sl<ApiClient>();
      final apiClient2 = sl<ApiClient>();

      final secureStorage1 = sl<SecureStorageService>();
      final secureStorage2 = sl<SecureStorageService>();

      // Assert - Singletons should return the same instance
      expect(identical(apiClient1, apiClient2), true);
      expect(identical(secureStorage1, secureStorage2), true);
    });

    test('should retrieve FlutterSecureStorage instance', () async {
      // Arrange
      await initializeDependencies();

      // Act
      final storage = sl<FlutterSecureStorage>();

      // Assert
      expect(storage, isA<FlutterSecureStorage>());
    });

    test('should retrieve SecureStorageService instance', () async {
      // Arrange
      await initializeDependencies();

      // Act
      final service = sl<SecureStorageService>();

      // Assert
      expect(service, isA<SecureStorageService>());
      expect(service, isA<SecureStorageServiceImpl>());
    });

    test('should retrieve Dio instance', () async {
      // Arrange
      await initializeDependencies();

      // Act
      final dio = sl<Dio>();

      // Assert
      expect(dio, isA<Dio>());
    });

    test('should retrieve ApiClient instance', () async {
      // Arrange
      await initializeDependencies();

      // Act
      final apiClient = sl<ApiClient>();

      // Assert
      expect(apiClient, isA<ApiClient>());
    });

    test('should properly inject dependencies into ApiClient', () async {
      // Arrange
      await initializeDependencies();

      // Act
      final apiClient = sl<ApiClient>();

      // Assert - ApiClient should be properly constructed with dependencies
      expect(apiClient, isNotNull);
      // The ApiClient should have been initialized with the registered dependencies
    });

    test('should properly inject dependencies into SecureStorageService', () async {
      // Arrange
      await initializeDependencies();

      // Act
      final secureStorageService = sl<SecureStorageService>();

      // Assert - SecureStorageService should be properly constructed
      expect(secureStorageService, isNotNull);
      expect(secureStorageService, isA<SecureStorageServiceImpl>());
    });

    test('should allow multiple initializations without errors', () async {
      // Act & Assert - Should not throw
      await initializeDependencies();
      
      // Reset and initialize again
      await sl.reset();
      await initializeDependencies();

      // Verify services are still registered
      expect(sl.isRegistered<ApiClient>(), true);
      expect(sl.isRegistered<SecureStorageService>(), true);
    });
  });
}
