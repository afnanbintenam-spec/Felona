# Network Layer

This directory contains the network infrastructure for the FeloNa application, including the centralized HTTP client and interceptors.

## Components

### SecureStorageService

The `SecureStorageService` provides an abstraction layer for secure storage operations, wrapping platform-native secure storage mechanisms.

**Features:**
- Platform-native secure storage (iOS Keychain, Android Keystore)
- Simple key-value storage interface
- Exception handling with domain-specific errors
- Support for JWT tokens and sensitive credentials

**Implementation:**
- `SecureStorageService`: Abstract interface
- `SecureStorageServiceImpl`: Concrete implementation using `flutter_secure_storage`

**Usage:**
```dart
final secureStorage = SecureStorageServiceImpl();

// Write data
await secureStorage.write('auth_token', jwtToken);

// Read data
final token = await secureStorage.read('auth_token');

// Delete specific key
await secureStorage.delete('auth_token');

// Delete all data
await secureStorage.deleteAll();
```

**Common Use Cases:**
- JWT token storage: `auth_token`
- User credentials: `user_email`, `user_id`
- Refresh tokens: `refresh_token`
- API keys: `api_key`

**Error Handling:**
All methods throw `StorageException` on failure:
```dart
try {
  await secureStorage.write('key', 'value');
} on StorageException catch (e) {
  print('Storage error: ${e.message} (${e.code})');
}
```

### ApiClient

The `ApiClient` class provides a configured Dio instance for making HTTP requests to the backend API.

**Features:**
- Centralized HTTP client configuration
- Base URL and timeout management
- Support for GET, POST, PUT, DELETE, PATCH requests
- Multipart form data upload support
- Automatic interceptor integration

**Usage:**
```dart
final apiClient = ApiClient(secureStorage: secureStorage);

// GET request
final response = await apiClient.get('/users');

// POST request
final response = await apiClient.post('/auth/login', data: {
  'email': 'user@example.com',
  'password': 'password123',
});

// File upload
final formData = FormData.fromMap({
  'file': await MultipartFile.fromFile(filePath),
});
final response = await apiClient.uploadMultipart('/upload', formData);
```

### Interceptors

The API client uses three interceptors that process requests and responses in the following order:

#### 1. AuthInterceptor

Automatically injects JWT tokens into request headers.

**Behavior:**
- Retrieves JWT token from secure storage
- Adds `Authorization: Bearer <token>` header to all requests
- Allows unauthenticated requests (login, register) to proceed without token
- Gracefully handles token retrieval failures

**Token Storage Key:** `auth_token`

#### 2. LoggingInterceptor

Logs HTTP requests and responses for debugging purposes.

**Logs:**
- Request method, URL, headers, body, and query parameters
- Response status code, headers, and body
- Error details including type and message

**Note:** Logging is enabled in all environments. Consider adding environment-based conditional logging for production builds.

#### 3. ErrorInterceptor

Transforms HTTP errors into domain-specific exceptions.

**Error Transformations:**

| HTTP Status | Exception Type | Description |
|------------|----------------|-------------|
| Timeout | `NetworkException` | Connection, send, or receive timeout |
| Connection Error | `NetworkException` | No internet connection |
| 400 | `ValidationException` | Bad request with field-level errors |
| 401 | `AuthenticationException` | Authentication failed |
| 403 | `AuthorizationException` | Access denied |
| 404 | `ServerException` | Resource not found |
| 409 | `ValidationException` | Conflict (e.g., duplicate entry) |
| 422 | `ValidationException` | Unprocessable entity |
| 429 | `ServerException` | Rate limit exceeded |
| 500-504 | `ServerException` | Server errors |

**Field Error Parsing:**

The interceptor supports multiple field error formats:

```json
// Format 1: Object
{
  "message": "Validation failed",
  "errors": {
    "email": "Invalid email format",
    "password": "Password too short"
  }
}

// Format 2: Array
{
  "message": "Validation failed",
  "errors": [
    { "field": "email", "message": "Invalid email" },
    { "field": "password", "message": "Too short" }
  ]
}

// Format 3: Alternative keys
{
  "message": "Validation failed",
  "field_errors": { ... }
}
```

## Configuration

### Base URL

Update the base URL in `api_client.dart`:

```dart
static const String baseUrl = 'https://api.felona.com';
```

### Timeout

Default timeout is 30 seconds. Modify in `api_client.dart`:

```dart
static const Duration timeout = Duration(seconds: 30);
```

## Testing

Unit tests are located in:
- `test/core/network/api_client_test.dart` - API client tests
- `test/core/network/secure_storage_service_test.dart` - Secure storage tests

**Test Coverage:**

**API Client:**
- API client instantiation
- Error transformation for all HTTP status codes
- Field error parsing in multiple formats
- Network error handling (timeout, connection, certificate)
- Null and empty response handling

**Secure Storage:**
- Write operations with success and failure scenarios
- Read operations including null returns
- Delete operations for specific keys
- Delete all operations
- Edge cases (empty strings, special characters, long values)

**Run tests:**
```bash
# Run all network tests
flutter test test/core/network/

# Run specific test file
flutter test test/core/network/api_client_test.dart
flutter test test/core/network/secure_storage_service_test.dart
```

## Error Handling Best Practices

When using the API client in repositories:

```dart
@override
Future<Either<Failure, User>> login(String email, String password) async {
  try {
    final response = await _apiClient.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    
    final user = UserModel.fromJson(response.data['user']);
    return Right(user);
  } on AuthenticationException catch (e) {
    return Left(AuthFailure(e.message, e.code));
  } on NetworkException catch (e) {
    return Left(NetworkFailure(e.message, e.code));
  } on ValidationException catch (e) {
    return Left(ValidationFailure(e.message, e.fieldErrors, e.code));
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message, e.code));
  } catch (e) {
    return Left(ServerFailure('Unexpected error: ${e.toString()}'));
  }
}
```

## Dependencies

- `dio`: ^5.7.0 - HTTP client
- `flutter_secure_storage`: ^9.2.2 - Secure token storage

## Future Enhancements

- [ ] Add retry logic for failed requests
- [ ] Implement request caching
- [ ] Add request/response encryption
- [ ] Environment-based logging configuration
- [ ] Token refresh mechanism
- [ ] Request queue for offline support
