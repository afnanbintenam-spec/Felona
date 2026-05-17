import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../errors/exceptions.dart';

/// Abstract interface for secure storage operations.
///
/// Provides a contract for securely storing sensitive data such as JWT tokens,
/// user credentials, and other confidential information. Implementations should
/// use platform-native secure storage mechanisms (iOS Keychain, Android Keystore).
abstract class SecureStorageService {
  /// Writes a key-value pair to secure storage.
  ///
  /// [key] The unique identifier for the stored value.
  /// [value] The data to store securely.
  ///
  /// Throws [StorageException] if the write operation fails.
  Future<void> write(String key, String value);

  /// Reads a value from secure storage.
  ///
  /// [key] The unique identifier for the stored value.
  ///
  /// Returns the stored value if found, or `null` if the key doesn't exist.
  /// Throws [StorageException] if the read operation fails.
  Future<String?> read(String key);

  /// Deletes a specific key-value pair from secure storage.
  ///
  /// [key] The unique identifier for the value to delete.
  ///
  /// Throws [StorageException] if the delete operation fails.
  Future<void> delete(String key);

  /// Deletes all key-value pairs from secure storage.
  ///
  /// This operation clears all stored data. Use with caution.
  ///
  /// Throws [StorageException] if the operation fails.
  Future<void> deleteAll();
}

/// Implementation of [SecureStorageService] using flutter_secure_storage.
///
/// Wraps the flutter_secure_storage package to provide secure storage
/// functionality using platform-native secure storage:
/// - iOS: Keychain
/// - Android: Keystore
/// - Web: Web Crypto API
/// - Windows/Linux/macOS: libsecret/Keychain
class SecureStorageServiceImpl implements SecureStorageService {
  final FlutterSecureStorage _storage;

  /// Creates a [SecureStorageServiceImpl] instance.
  ///
  /// [storage] Optional FlutterSecureStorage instance for dependency injection.
  /// If not provided, creates a new instance with default Android options.
  SecureStorageServiceImpl({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            );

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw StorageException(
        'Failed to write to secure storage: ${e.toString()}',
        'WRITE_ERROR',
      );
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw StorageException(
        'Failed to read from secure storage: ${e.toString()}',
        'READ_ERROR',
      );
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw StorageException(
        'Failed to delete from secure storage: ${e.toString()}',
        'DELETE_ERROR',
      );
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw StorageException(
        'Failed to delete all from secure storage: ${e.toString()}',
        'DELETE_ALL_ERROR',
      );
    }
  }
}
