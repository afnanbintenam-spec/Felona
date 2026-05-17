# Dependency Injection

This directory contains the dependency injection setup for the FeloNa application using the GetIt service locator pattern.

## Overview

The dependency injection container manages all application dependencies, ensuring proper initialization order and providing a centralized location for dependency registration.

## Files

- **`injection_container.dart`**: Main DI container setup with service registration

## Usage

### Initialization

The DI container is initialized in `main.dart` before the app starts:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  runApp(const FeloNaApp());
}
```

### Retrieving Dependencies

Use the `sl` (service locator) instance to retrieve registered dependencies:

```dart
import 'package:felo_na/core/di/injection_container.dart';

// Retrieve a registered service
final apiClient = sl<ApiClient>();
final secureStorage = sl<SecureStorageService>();
```

## Registered Services

### Core Services

The following core services are registered as lazy singletons:

1. **FlutterSecureStorage**: Platform-native secure storage
2. **SecureStorageService**: Abstraction over FlutterSecureStorage
3. **Dio**: HTTP client
4. **ApiClient**: Configured HTTP client with interceptors

### Registration Types

- **Lazy Singleton** (`registerLazySingleton`): Creates a single instance on first access, reused for all subsequent requests
- **Factory** (`registerFactory`): Creates a new instance each time it's requested (used for BLoCs)

## Adding New Dependencies

When implementing new features, add their dependencies to the container:

1. Create a feature-specific initialization function (e.g., `_initAuthDependencies()`)
2. Register data sources, repositories, use cases, and BLoCs
3. Call the initialization function from `initializeDependencies()`

### Example: Authentication Feature

```dart
void _initAuthDependencies() {
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));

  // BLoC (use factory for BLoCs to create new instances)
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
    ),
  );
}
```

Then call it from `initializeDependencies()`:

```dart
Future<void> initializeDependencies() async {
  // Core services...
  
  // Feature dependencies
  _initAuthDependencies();
  _initMarketplaceDependencies();
  // ... other features
}
```

## Testing

The DI container can be reset and re-initialized in tests:

```dart
setUp(() async {
  await sl.reset();
  await initializeDependencies();
});
```

For unit tests, you can register mock implementations:

```dart
sl.registerLazySingleton<AuthRepository>(() => MockAuthRepository());
```

## Best Practices

1. **Register interfaces, not implementations**: Register abstract classes/interfaces when possible
2. **Use lazy singletons for services**: Most services should be lazy singletons
3. **Use factories for BLoCs**: BLoCs should be created fresh for each screen
4. **Keep initialization order correct**: Register dependencies before dependents
5. **Group related dependencies**: Use feature-specific initialization functions
6. **Document complex dependencies**: Add comments for non-obvious dependency relationships

## Architecture

The DI setup follows Clean Architecture principles:

```
Presentation Layer (BLoCs, Widgets)
        ↓
Domain Layer (Use Cases, Repositories)
        ↓
Data Layer (Data Sources, API Client)
        ↓
Core Layer (Network, Storage)
```

Dependencies flow from outer layers (presentation) to inner layers (core), with the DI container managing the wiring.
