import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage keys for auth tokens.
class TokenKeys {
  static const String accessToken = 'auth_token';
  static const String refreshToken = 'refresh_token';

  TokenKeys._();
}

/// Production-grade auth interceptor with automatic token refresh.
///
/// Handles:
/// - Attaching access token to every request
/// - Detecting 401 responses
/// - Silently refreshing the token using refresh token
/// - Retrying the original failed request
/// - Queuing concurrent requests during refresh
/// - Forcing logout when refresh fails
class AuthRefreshInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  final String _baseUrl;
  final void Function()? onForceLogout;

  bool _isRefreshing = false;

  AuthRefreshInterceptor({
    required Dio dio,
    required FlutterSecureStorage storage,
    required String baseUrl,
    this.onForceLogout,
  })  : _dio = dio,
        _storage = storage,
        _baseUrl = baseUrl;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip token for auth endpoints that don't need it
    final noAuthPaths = [
      '/auth/login',
      '/auth/register',
      '/auth/refresh',
      '/auth/verify-email',
      '/auth/verify-reset-otp',
      '/auth/resend-verification',
      '/auth/resend-reset-otp',
      '/auth/forgot-password',
    ];

    final needsAuth = !noAuthPaths.any((p) => options.path.contains(p));

    if (needsAuth) {
      final token = await _storage.read(key: TokenKeys.accessToken);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only handle 401 Unauthorized
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Don't retry refresh endpoint itself (avoid infinite loop)
    if (err.requestOptions.path.contains('/auth/refresh')) {
      await _clearTokensAndLogout();
      handler.next(err);
      return;
    }

    // Don't retry login/register failures
    final skipPaths = ['/auth/login', '/auth/register'];
    if (skipPaths.any((p) => err.requestOptions.path.contains(p))) {
      handler.next(err);
      return;
    }

    // Attempt token refresh
    final refreshed = await _refreshToken();

    if (refreshed) {
      // Retry the original request with new token
      try {
        final newToken = await _storage.read(key: TokenKeys.accessToken);
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newToken';

        final response = await _dio.fetch(opts);
        handler.resolve(response);
      } catch (e) {
        handler.next(err);
      }
    } else {
      // Refresh failed — force logout
      await _clearTokensAndLogout();
      handler.next(err);
    }
  }

  /// Attempts to refresh the access token using the stored refresh token.
  /// Returns true if refresh succeeded, false otherwise.
  Future<bool> _refreshToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;

    try {
      final refreshToken = await _storage.read(key: TokenKeys.refreshToken);

      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      // Use a separate Dio instance to avoid interceptor loops
      final refreshDio = Dio(BaseOptions(
        baseUrl: _baseUrl,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'] ??
            response.data['token'] ??
            response.data['access_token'];
        final newRefreshToken = response.data['refreshToken'] ??
            response.data['refresh_token'];

        if (newAccessToken != null) {
          await _storage.write(
            key: TokenKeys.accessToken,
            value: newAccessToken as String,
          );
        }

        // If backend rotates refresh tokens, save the new one
        if (newRefreshToken != null) {
          await _storage.write(
            key: TokenKeys.refreshToken,
            value: newRefreshToken as String,
          );
        }

        return newAccessToken != null;
      }

      return false;
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Clears all tokens and triggers logout callback.
  Future<void> _clearTokensAndLogout() async {
    await _storage.delete(key: TokenKeys.accessToken);
    await _storage.delete(key: TokenKeys.refreshToken);
    onForceLogout?.call();
  }
}
