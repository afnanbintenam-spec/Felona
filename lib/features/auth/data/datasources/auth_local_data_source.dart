import 'dart:convert';

import 'package:felo_na/core/errors/exceptions.dart';
import 'package:felo_na/core/network/secure_storage_service.dart';
import 'package:felo_na/features/auth/data/models/user_model.dart';

/// Abstract interface for the authentication local data source.
///
/// Defines the contract for local storage operations related to authentication,
/// including JWT token persistence and cached user data management.
/// Uses [SecureStorageService] for secure token storage and user data caching.
abstract class AuthLocalDataSource {
  /// Saves the JWT authentication token to secure storage.
  ///
  /// [token] The JWT token string to persist.
  /// Throws [StorageException] if the save operation fails.
  Future<void> saveToken(String token);

  /// Retrieves the stored JWT authentication token.
  ///
  /// Returns the token string if one is stored, or `null` if no token exists.
  /// Throws [StorageException] if the read operation fails.
  Future<String?> getToken();

  /// Deletes the stored JWT authentication token.
  ///
  /// Throws [StorageException] if the delete operation fails.
  Future<void> deleteToken();

  /// Saves the user data to local cache.
  ///
  /// [user] The [UserModel] to cache locally as JSON.
  /// Throws [StorageException] if the save operation fails.
  Future<void> saveUser(UserModel user);

  /// Retrieves the cached user data.
  ///
  /// Returns the cached [UserModel] if available, or `null` if no user is cached.
  /// Throws [StorageException] if the read operation fails or cached data is corrupted.
  Future<UserModel?> getUser();

  /// Deletes the cached user data.
  ///
  /// Throws [StorageException] if the delete operation fails.
  Future<void> deleteUser();

  /// Clears all authentication-related local data (token and cached user).
  ///
  /// This is typically called during logout to ensure no stale data remains.
  /// Throws [StorageException] if the operation fails.
  Future<void> clearAll();
}

/// Implementation of [AuthLocalDataSource] using [SecureStorageService].
///
/// Stores the JWT token directly in secure storage and caches user data
/// as a JSON-encoded string. Uses platform-native secure storage mechanisms
/// (iOS Keychain, Android Keystore) via [SecureStorageService].
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService _secureStorage;

  /// Storage key for the JWT authentication token.
  static const String _tokenKey = 'auth_token';

  /// Storage key for the cached user data (JSON-encoded).
  static const String _userKey = 'cached_user';

  /// Creates an [AuthLocalDataSourceImpl] instance.
  ///
  /// [secureStorage] The secure storage service for persisting data.
  AuthLocalDataSourceImpl({required SecureStorageService secureStorage})
      : _secureStorage = secureStorage;

  @override
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(_tokenKey, token);
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException(
        'Failed to save authentication token: ${e.toString()}',
        'TOKEN_SAVE_ERROR',
      );
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(_tokenKey);
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException(
        'Failed to retrieve authentication token: ${e.toString()}',
        'TOKEN_READ_ERROR',
      );
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(_tokenKey);
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException(
        'Failed to delete authentication token: ${e.toString()}',
        'TOKEN_DELETE_ERROR',
      );
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final jsonString = jsonEncode(user.toJson());
      await _secureStorage.write(_userKey, jsonString);
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException(
        'Failed to save cached user data: ${e.toString()}',
        'USER_SAVE_ERROR',
      );
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final jsonString = await _secureStorage.read(_userKey);
      if (jsonString == null) return null;

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserModel.fromJson(jsonMap);
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException(
        'Failed to retrieve cached user data: ${e.toString()}',
        'USER_READ_ERROR',
      );
    }
  }

  @override
  Future<void> deleteUser() async {
    try {
      await _secureStorage.delete(_userKey);
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException(
        'Failed to delete cached user data: ${e.toString()}',
        'USER_DELETE_ERROR',
      );
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await _secureStorage.delete(_tokenKey);
      await _secureStorage.delete(_userKey);
    } on StorageException {
      rethrow;
    } catch (e) {
      throw StorageException(
        'Failed to clear authentication data: ${e.toString()}',
        'CLEAR_ALL_ERROR',
      );
    }
  }
}
