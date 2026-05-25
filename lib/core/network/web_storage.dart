import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A storage wrapper that works on all platforms including web.
/// On web, flutter_secure_storage uses localStorage internally,
/// but this wrapper ensures no exceptions are thrown.
class AppStorage {
  final FlutterSecureStorage _storage;
  
  // In-memory fallback for web if secure storage fails
  static final Map<String, String> _memoryStore = {};

  AppStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              webOptions: WebOptions(
                dbName: 'felona_auth',
                publicKey: 'felona_public_key',
              ),
            );

  Future<void> write({required String key, required String value}) async {
    if (kIsWeb) {
      // On web, use memory store as reliable fallback
      _memoryStore[key] = value;
      try {
        await _storage.write(key: key, value: value);
      } catch (_) {
        // Silently fall back to memory store on web
      }
    } else {
      await _storage.write(key: key, value: value);
    }
  }

  Future<String?> read({required String key}) async {
    if (kIsWeb) {
      try {
        final value = await _storage.read(key: key);
        if (value != null) return value;
      } catch (_) {
        // Fall back to memory store
      }
      return _memoryStore[key];
    } else {
      return await _storage.read(key: key);
    }
  }

  Future<void> delete({required String key}) async {
    _memoryStore.remove(key);
    try {
      await _storage.delete(key: key);
    } catch (_) {
      // Ignore on web
    }
  }
}
