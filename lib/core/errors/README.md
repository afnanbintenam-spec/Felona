# Error Handling System

This directory contains the core error handling infrastructure for the FeloNa application. The error handling system follows a layered approach that transforms low-level exceptions into domain-specific failures.

## Architecture

The error handling system consists of three main components:

### 1. Exceptions (`exceptions.dart`)

Exceptions are thrown at the data layer (repositories, data sources) when operations fail. They represent technical errors from external systems (network, storage, APIs).

**Exception Hierarchy:**
- `AppException` - Base class for all application exceptions
  - `NetworkException` - Network-related errors (timeouts, no connection)
  - `AuthenticationException` - Authentication failures (invalid credentials, expired tokens)
  - `ValidationException` - Input validation errors with field-level details
  - `AuthorizationException` - Permission/access denied errors
  - `ServerException` - Server-side errors (5xx responses)
  - `StorageException` - Local storage operation failures

**Usage Example:**
```dart
// In a data source
Future<UserModel> login(String email, String password) async {
  try {
    final response = await dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return UserModel.fromJson(response.data);
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      throw const AuthenticationException('Invalid credentials', 'AUTH_001');
    }
    throw NetworkException('Connection failed: ${e.message}');
  }
}
```

### 2. Failures (`failures.dart`)

Failures are returned from the domain layer (use cases, repositories) to the presentation layer. They represent business-level errors that can be displayed to users.

**Failure Hierarchy:**
- `Failure` - Base class for all failures (extends Equatable for value equality)
  - `NetworkFailure` - Network-related failures
  - `AuthFailure` - Authentication failures
  - `ValidationFailure` - Validation failures with field errors
  - `AuthorizationFailure` - Authorization failures
  - `ServerFailure` - Server-side failures
  - `StorageFailure` - Storage operation failures

**Usage Example:**
```dart
// In a repository
@override
Future<Either<Failure, User>> login(String email, String password) async {
  try {
    final user = await remoteDataSource.login(email, password);
    await localDataSource.cacheUser(user);
    return Right(user);
  } on AuthenticationException catch (e) {
    return Left(AuthFailure(e.message, e.code));
  } on NetworkException catch (e) {
    return Left(NetworkFailure(e.message, e.code));
  } catch (e) {
    return Left(ServerFailure('Unexpected error: ${e.toString()}'));
  }
}
```

### 3. Error Handler (`error_handler.dart`)

The `ErrorHandler` utility class provides a centralized way to transform exceptions into failures, ensuring consistent error handling across all repositories.

**Usage Example:**
```dart
// In a repository using ErrorHandler
@override
Future<Either<Failure, User>> login(String email, String password) async {
  try {
    final user = await remoteDataSource.login(email, password);
    await localDataSource.cacheUser(user);
    return Right(user);
  } catch (e) {
    return Left(ErrorHandler.handleException(e));
  }
}
```

## Error Flow

```
┌─────────────────┐
│  Data Source    │ Throws Exception
│  (API/Storage)  │ (NetworkException, AuthenticationException, etc.)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Repository    │ Catches Exception
│                 │ Transforms to Failure using ErrorHandler
│                 │ Returns Either<Failure, Success>
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    Use Case     │ Receives Either<Failure, Success>
│                 │ Passes through to BLoC
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│      BLoC       │ Handles Failure
│                 │ Emits Error State with user-friendly message
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│       UI        │ Displays error to user
│                 │ (SnackBar, Dialog, Inline message)
└─────────────────┘
```

## Best Practices

### 1. Exception Handling in Data Sources

Always throw specific exception types with meaningful messages:

```dart
// ✅ Good
if (response.statusCode == 400) {
  throw ValidationException(
    'Invalid input',
    {'email': 'Email format is invalid'},
    'VAL_001',
  );
}

// ❌ Bad
if (response.statusCode == 400) {
  throw Exception('Bad request');
}
```

### 2. Error Transformation in Repositories

Use `ErrorHandler.handleException()` for consistent error transformation:

```dart
// ✅ Good
try {
  final result = await dataSource.fetchData();
  return Right(result);
} catch (e) {
  return Left(ErrorHandler.handleException(e));
}

// ❌ Bad - Manual transformation is error-prone
try {
  final result = await dataSource.fetchData();
  return Right(result);
} catch (e) {
  if (e is NetworkException) {
    return Left(NetworkFailure(e.message));
  }
  // Missing other exception types...
}
```

### 3. Error Display in UI

Map failures to user-friendly messages:

```dart
String _mapFailureToMessage(Failure failure) {
  if (failure is NetworkFailure) {
    return 'No internet connection. Please check your network.';
  } else if (failure is AuthFailure) {
    return 'Invalid email or password.';
  } else if (failure is ValidationFailure) {
    // Display field-specific errors
    return failure.message;
  } else {
    return 'An unexpected error occurred. Please try again.';
  }
}
```

### 4. Field-Level Validation Errors

Use `ValidationFailure.fieldErrors` to display inline error messages:

```dart
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthError && state.failure is ValidationFailure) {
      final fieldErrors = (state.failure as ValidationFailure).fieldErrors;
      return Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Email',
              errorText: fieldErrors['email'],
            ),
          ),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Password',
              errorText: fieldErrors['password'],
            ),
          ),
        ],
      );
    }
    // ... other states
  },
)
```

## Error Codes

Error codes are optional but recommended for:
- Logging and debugging
- Analytics and error tracking
- Internationalization (i18n) of error messages
- API error mapping

**Suggested Code Format:**
- `NET_xxx` - Network errors
- `AUTH_xxx` - Authentication errors
- `AUTHZ_xxx` - Authorization errors
- `VAL_xxx` - Validation errors
- `SRV_xxx` - Server errors
- `STR_xxx` - Storage errors

## Testing

All error handling classes include comprehensive unit tests:

- `exceptions_test.dart` - Tests for all exception types
- `failures_test.dart` - Tests for all failure types (including Equatable equality)
- `error_handler_test.dart` - Tests for exception-to-failure transformation

Run tests with:
```bash
flutter test test/core/errors/
```

## Integration with Dio

The error handling system integrates with Dio through an `ErrorInterceptor` (implemented in `lib/core/network/api_client.dart`):

```dart
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException exception;
    
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        exception = NetworkException('Connection timeout');
        break;
      case DioExceptionType.badResponse:
        exception = _handleResponseError(err.response);
        break;
      // ... other cases
    }
    
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: exception,
    ));
  }
}
```

## Summary

The error handling system provides:

✅ **Type Safety** - Specific exception and failure types for different error scenarios  
✅ **Consistency** - Centralized error transformation through `ErrorHandler`  
✅ **Testability** - All classes are fully unit tested  
✅ **User Experience** - Field-level validation errors and user-friendly messages  
✅ **Debugging** - Optional error codes and detailed error information  
✅ **Maintainability** - Clear separation between technical exceptions and business failures
