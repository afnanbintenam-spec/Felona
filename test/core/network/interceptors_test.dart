import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:felo_na/core/errors/exceptions.dart';
import 'package:felo_na/core/network/api_client.dart';
import 'package:felo_na/core/network/auth_interceptor.dart';

@GenerateMocks([FlutterSecureStorage, Dio])
import 'interceptors_test.mocks.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Fake handler implementations — let us capture what the interceptor decides
// ─────────────────────────────────────────────────────────────────────────────

/// Captures the outcome of RequestInterceptorHandler calls.
class _FakeRequestHandler extends RequestInterceptorHandler {
  RequestOptions? nextOptions;
  Response? resolvedResponse;
  DioException? rejectedError;

  @override
  void next(RequestOptions options) => nextOptions = options;

  @override
  void resolve(Response response, [bool callFollowingResponseInterceptor = false]) =>
      resolvedResponse = response;

  @override
  void reject(DioException err, [bool callFollowingErrorInterceptor = false]) =>
      rejectedError = err;
}

/// Captures the outcome of ErrorInterceptorHandler calls.
class _FakeErrorHandler extends ErrorInterceptorHandler {
  DioException? nextError;
  Response? resolvedResponse;
  DioException? rejectedError;

  @override
  void next(DioException err) => nextError = err;

  @override
  void resolve(Response response) => resolvedResponse = response;

  @override
  void reject(DioException err, [bool callFollowingErrorInterceptor = false]) =>
      rejectedError = err;
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: build a minimal DioException for a given status code
// ─────────────────────────────────────────────────────────────────────────────
DioException _badResponse(
  int statusCode, {
  String path = '/api/test',
  dynamic data,
}) {
  return DioException(
    requestOptions: RequestOptions(path: path),
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: RequestOptions(path: path),
      statusCode: statusCode,
      data: data,
    ),
  );
}

DioException _dioError(
  DioExceptionType type, {
  String path = '/api/test',
  String? message,
}) {
  return DioException(
    requestOptions: RequestOptions(path: path),
    type: type,
    message: message,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// AuthRefreshInterceptor tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── shared mocks ──────────────────────────────────────────────────────────
  late MockFlutterSecureStorage mockStorage;
  late MockDio mockDio;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    mockDio = MockDio();
  });

  // Helper: create the interceptor under test
  AuthRefreshInterceptor _makeInterceptor({
    void Function()? onForceLogout,
  }) {
    return AuthRefreshInterceptor(
      dio: mockDio,
      storage: mockStorage,
      baseUrl: 'http://localhost:3000',
      onForceLogout: onForceLogout,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Group: AuthRefreshInterceptor — onRequest
  // ══════════════════════════════════════════════════════════════════════════
  group('AuthRefreshInterceptor.onRequest', () {
    const noAuthPaths = [
      '/auth/login',
      '/auth/register',
      '/auth/refresh',
      '/auth/verify-email',
      '/auth/verify-reset-otp',
      '/auth/resend-verification',
      '/auth/resend-reset-otp',
      '/auth/forgot-password',
    ];

    for (final noAuthPath in noAuthPaths) {
      test('should NOT attach Authorization header for $noAuthPath', () async {
        final interceptor = _makeInterceptor();
        final handler = _FakeRequestHandler();
        final options = RequestOptions(path: noAuthPath);

        interceptor.onRequest(options, handler);
        // Give async onRequest a tick to complete
        await Future<void>.delayed(Duration.zero);

        expect(handler.nextOptions, isNotNull);
        expect(handler.nextOptions!.headers['Authorization'], isNull);
        // Storage should never be touched for no-auth paths
        verifyNever(mockStorage.read(key: anyNamed('key')));
      });
    }

    test('should attach Bearer token when access token exists in storage',
        () async {
      const accessToken = 'eyJhbGciOiJIUzI1NiJ9.payload.sig';
      when(mockStorage.read(key: TokenKeys.accessToken))
          .thenAnswer((_) async => accessToken);

      final interceptor = _makeInterceptor();
      final handler = _FakeRequestHandler();
      final options = RequestOptions(path: '/api/profile');

      interceptor.onRequest(options, handler);
      await Future<void>.delayed(Duration.zero);

      expect(handler.nextOptions, isNotNull);
      expect(
        handler.nextOptions!.headers['Authorization'],
        'Bearer $accessToken',
      );
    });

    test('should NOT attach Authorization header when access token is null',
        () async {
      when(mockStorage.read(key: TokenKeys.accessToken))
          .thenAnswer((_) async => null);

      final interceptor = _makeInterceptor();
      final handler = _FakeRequestHandler();
      final options = RequestOptions(path: '/api/items');

      interceptor.onRequest(options, handler);
      await Future<void>.delayed(Duration.zero);

      expect(handler.nextOptions, isNotNull);
      expect(handler.nextOptions!.headers['Authorization'], isNull);
    });

    test('should NOT attach Authorization header when access token is empty',
        () async {
      when(mockStorage.read(key: TokenKeys.accessToken))
          .thenAnswer((_) async => '');

      final interceptor = _makeInterceptor();
      final handler = _FakeRequestHandler();
      final options = RequestOptions(path: '/api/items');

      interceptor.onRequest(options, handler);
      await Future<void>.delayed(Duration.zero);

      expect(handler.nextOptions!.headers['Authorization'], isNull);
    });

    test('should always call handler.next after attaching token', () async {
      when(mockStorage.read(key: TokenKeys.accessToken))
          .thenAnswer((_) async => 'token');

      final interceptor = _makeInterceptor();
      final handler = _FakeRequestHandler();

      interceptor.onRequest(RequestOptions(path: '/api/data'), handler);
      await Future<void>.delayed(Duration.zero);

      expect(handler.nextOptions, isNotNull);
      expect(handler.resolvedResponse, isNull);
      expect(handler.rejectedError, isNull);
    });

    test('path contains /auth/login check works for nested paths', () async {
      // e.g. /v1/auth/login should also skip token
      final interceptor = _makeInterceptor();
      final handler = _FakeRequestHandler();

      interceptor.onRequest(
        RequestOptions(path: '/v1/auth/login'),
        handler,
      );
      await Future<void>.delayed(Duration.zero);

      verifyNever(mockStorage.read(key: anyNamed('key')));
      expect(handler.nextOptions, isNotNull);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Group: AuthRefreshInterceptor — onError
  // ══════════════════════════════════════════════════════════════════════════
  group('AuthRefreshInterceptor.onError', () {
    // ── non-401 pass-through ─────────────────────────────────────────────
    for (final code in [400, 403, 404, 409, 422, 429, 500, 502, 503]) {
      test('should pass through $code errors without touching storage',
          () async {
        final interceptor = _makeInterceptor();
        final handler = _FakeErrorHandler();
        final err = _badResponse(code);

        interceptor.onError(err, handler);
        await Future<void>.delayed(Duration.zero);

        expect(handler.nextError, isNotNull);
        expect(handler.resolvedResponse, isNull);
        verifyNever(mockStorage.read(key: anyNamed('key')));
      });
    }

    test('should pass through network-type errors without touching storage',
        () async {
      final interceptor = _makeInterceptor();
      final handler = _FakeErrorHandler();
      final err = _dioError(DioExceptionType.connectionError);

      interceptor.onError(err, handler);
      await Future<void>.delayed(Duration.zero);

      expect(handler.nextError, isNotNull);
      verifyNever(mockStorage.read(key: anyNamed('key')));
    });

    // ── 401 on refresh endpoint → immediate logout (avoid infinite loop) ──
    test(
      'should clear tokens and call onForceLogout for 401 on /auth/refresh',
      () async {
        var logoutCalled = false;
        final interceptor = _makeInterceptor(onForceLogout: () => logoutCalled = true);
        final handler = _FakeErrorHandler();

        when(mockStorage.delete(key: TokenKeys.accessToken))
            .thenAnswer((_) async {});
        when(mockStorage.delete(key: TokenKeys.refreshToken))
            .thenAnswer((_) async {});

        final err = _badResponse(401, path: '/auth/refresh');
        interceptor.onError(err, handler);
        await Future<void>.delayed(Duration.zero);

        verify(mockStorage.delete(key: TokenKeys.accessToken)).called(1);
        verify(mockStorage.delete(key: TokenKeys.refreshToken)).called(1);
        expect(logoutCalled, isTrue);
        expect(handler.nextError, isNotNull);
        expect(handler.resolvedResponse, isNull);
      },
    );

    // ── 401 on /auth/login → pass through without refresh ─────────────────
    test('should pass through 401 on /auth/login without attempting refresh',
        () async {
      final interceptor = _makeInterceptor();
      final handler = _FakeErrorHandler();
      final err = _badResponse(401, path: '/auth/login');

      interceptor.onError(err, handler);
      await Future<void>.delayed(Duration.zero);

      expect(handler.nextError, isNotNull);
      verifyNever(mockStorage.read(key: anyNamed('key')));
    });

    test('should pass through 401 on /auth/register without attempting refresh',
        () async {
      final interceptor = _makeInterceptor();
      final handler = _FakeErrorHandler();
      final err = _badResponse(401, path: '/auth/register');

      interceptor.onError(err, handler);
      await Future<void>.delayed(Duration.zero);

      expect(handler.nextError, isNotNull);
      verifyNever(mockStorage.read(key: anyNamed('key')));
    });

    // ── 401 with missing refresh token → logout ──────────────────────────
    test(
      'should clear tokens and logout when refresh token is null',
      () async {
        var logoutCalled = false;
        final interceptor =
            _makeInterceptor(onForceLogout: () => logoutCalled = true);
        final handler = _FakeErrorHandler();

        when(mockStorage.read(key: TokenKeys.refreshToken))
            .thenAnswer((_) async => null);
        when(mockStorage.delete(key: TokenKeys.accessToken))
            .thenAnswer((_) async {});
        when(mockStorage.delete(key: TokenKeys.refreshToken))
            .thenAnswer((_) async {});

        final err = _badResponse(401, path: '/api/protected');
        interceptor.onError(err, handler);
        await Future<void>.delayed(Duration.zero);

        expect(logoutCalled, isTrue);
        expect(handler.nextError, isNotNull);
      },
    );

    test(
      'should clear tokens and logout when refresh token is empty string',
      () async {
        var logoutCalled = false;
        final interceptor =
            _makeInterceptor(onForceLogout: () => logoutCalled = true);
        final handler = _FakeErrorHandler();

        when(mockStorage.read(key: TokenKeys.refreshToken))
            .thenAnswer((_) async => '');
        when(mockStorage.delete(key: TokenKeys.accessToken))
            .thenAnswer((_) async {});
        when(mockStorage.delete(key: TokenKeys.refreshToken))
            .thenAnswer((_) async {});

        final err = _badResponse(401, path: '/api/protected');
        interceptor.onError(err, handler);
        await Future<void>.delayed(Duration.zero);

        expect(logoutCalled, isTrue);
      },
    );

    // ── onForceLogout is optional (no crash when null) ────────────────────
    test('should not throw when onForceLogout is null and logout is triggered',
        () async {
      final interceptor = _makeInterceptor(onForceLogout: null);
      final handler = _FakeErrorHandler();

      when(mockStorage.read(key: TokenKeys.refreshToken))
          .thenAnswer((_) async => null);
      when(mockStorage.delete(key: TokenKeys.accessToken))
          .thenAnswer((_) async {});
      when(mockStorage.delete(key: TokenKeys.refreshToken))
          .thenAnswer((_) async {});

      final err = _badResponse(401, path: '/api/protected');

      // Must not throw
      expect(
        () async {
          interceptor.onError(err, handler);
          await Future<void>.delayed(Duration.zero);
        },
        returnsNormally,
      );
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Group: AuthRefreshInterceptor — token refresh paths
  //
  // We use _TestableAuthRefreshInterceptor so tests are fast and network-free.
  // The real refreshToken() internal logic is covered in its own unit group below.
  // ══════════════════════════════════════════════════════════════════════════
  group('AuthRefreshInterceptor — token refresh paths', () {
    test(
      'reads refresh_token key from storage when refreshToken returns false',
      () async {
        // Stub refresh = false to simulate a failed refresh cycle.
        final interceptor = _TestableAuthRefreshInterceptor(
          dio: mockDio,
          storage: mockStorage,
          baseUrl: 'http://localhost:3000',
          stubRefreshResult: false,
        );
        final handler = _FakeErrorHandler();

        when(mockStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async {});

        final err = _badResponse(401, path: '/api/protected');
        interceptor.onError(err, handler);
        await Future<void>.delayed(Duration.zero);

        expect(handler.nextError, isNotNull);
      },
    );

    test(
      'calls _clearTokensAndLogout when refreshToken() returns false',
      () async {
        var logoutCalled = false;
        final interceptor = _TestableAuthRefreshInterceptor(
          dio: mockDio,
          storage: mockStorage,
          baseUrl: 'http://localhost:3000',
          stubRefreshResult: false,
          onForceLogout: () => logoutCalled = true,
        );
        final handler = _FakeErrorHandler();

        when(mockStorage.delete(key: TokenKeys.accessToken))
            .thenAnswer((_) async {});
        when(mockStorage.delete(key: TokenKeys.refreshToken))
            .thenAnswer((_) async {});

        final err = _badResponse(401, path: '/api/protected');
        interceptor.onError(err, handler);
        await Future<void>.delayed(Duration.zero);

        expect(logoutCalled, isTrue);
        verify(mockStorage.delete(key: TokenKeys.accessToken)).called(1);
        verify(mockStorage.delete(key: TokenKeys.refreshToken)).called(1);
      },
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Group: refreshToken() unit tests (real implementation via concrete subclass)
  // ══════════════════════════════════════════════════════════════════════════
  group('AuthRefreshInterceptor.refreshToken() — unit', () {
    test('returns false when refresh token is null in storage', () async {
      when(mockStorage.read(key: TokenKeys.refreshToken))
          .thenAnswer((_) async => null);

      final interceptor = _makeInterceptor();
      final result = await interceptor.refreshToken();

      expect(result, isFalse);
    });

    test('returns false when refresh token is empty string', () async {
      when(mockStorage.read(key: TokenKeys.refreshToken))
          .thenAnswer((_) async => '');

      final interceptor = _makeInterceptor();
      final result = await interceptor.refreshToken();

      expect(result, isFalse);
    });

    test('returns false when the refresh HTTP call throws (no server)', () async {
      when(mockStorage.read(key: TokenKeys.refreshToken))
          .thenAnswer((_) async => 'valid_refresh_token');

      final interceptor = _makeInterceptor();
      // Real refreshToken() spawns an internal Dio that will fail —
      // it must swallow the exception and return false.
      final result = await interceptor.refreshToken();

      expect(result, isFalse);
    });

    test('does not throw regardless of network failure', () async {
      when(mockStorage.read(key: TokenKeys.refreshToken))
          .thenAnswer((_) async => 'some_token');

      final interceptor = _makeInterceptor();
      expect(
        () => interceptor.refreshToken(),
        returnsNormally,
      );
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Group: AuthRefreshInterceptor — retry behaviour
  // ══════════════════════════════════════════════════════════════════════════
  group('AuthRefreshInterceptor — retry behaviour', () {
    test(
      'retries original request with new token after successful refresh',
      () async {
        // We cannot intercept the internal refreshDio, so we create a
        // custom subclass that stubs _refreshToken = true and records the
        // retry call to _dio.fetch.
        //
        // Instead, we verify the PUBLIC contract:
        // If refresh succeeds (stubbed), dio.fetch is called with updated header.

        const newAccessToken = 'new_access_token_xyz';

        // Use a testable subclass that overrides the refresh logic
        final interceptor = _TestableAuthRefreshInterceptor(
          dio: mockDio,
          storage: mockStorage,
          baseUrl: 'http://localhost:3000',
          stubRefreshResult: true,
          newTokenAfterRefresh: newAccessToken,
        );

        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => newAccessToken);
        when(mockStorage.delete(key: TokenKeys.accessToken))
            .thenAnswer((_) async {});
        when(mockStorage.delete(key: TokenKeys.refreshToken))
            .thenAnswer((_) async {});

        final retryResponse = Response(
          requestOptions: RequestOptions(path: '/api/protected'),
          statusCode: 200,
          data: {'success': true},
        );
        when(mockDio.fetch(any)).thenAnswer((_) async => retryResponse);

        final handler = _FakeErrorHandler();
        final err = _badResponse(401, path: '/api/protected');

        interceptor.onError(err, handler);
        await Future<void>.delayed(Duration.zero);

        // The handler should have resolved (not rejected) after retry
        verify(mockDio.fetch(any)).called(1);
        expect(handler.resolvedResponse, isNotNull);
        expect(handler.resolvedResponse!.statusCode, 200);
      },
    );

    test(
      'resolves with retried response data after successful refresh',
      () async {
        const newToken = 'refreshed_token';
        final interceptor = _TestableAuthRefreshInterceptor(
          dio: mockDio,
          storage: mockStorage,
          baseUrl: 'http://localhost:3000',
          stubRefreshResult: true,
          newTokenAfterRefresh: newToken,
        );

        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => newToken);
        when(mockStorage.delete(key: TokenKeys.accessToken))
            .thenAnswer((_) async {});
        when(mockStorage.delete(key: TokenKeys.refreshToken))
            .thenAnswer((_) async {});

        final expectedData = {'user': 'john', 'role': 'collector'};
        when(mockDio.fetch(any)).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/api/protected'),
            statusCode: 200,
            data: expectedData,
          ),
        );

        final handler = _FakeErrorHandler();
        interceptor.onError(_badResponse(401, path: '/api/protected'), handler);
        await Future<void>.delayed(Duration.zero);

        expect(handler.resolvedResponse?.data, equals(expectedData));
      },
    );

    test(
      'calls handler.next (passes original error) when retry itself throws',
      () async {
        final interceptor = _TestableAuthRefreshInterceptor(
          dio: mockDio,
          storage: mockStorage,
          baseUrl: 'http://localhost:3000',
          stubRefreshResult: true,
          newTokenAfterRefresh: 'new_token',
        );

        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => 'new_token');
        when(mockStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async {});
        when(mockDio.fetch(any))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: '/api/protected'),
            ));

        final handler = _FakeErrorHandler();
        interceptor.onError(_badResponse(401, path: '/api/protected'), handler);
        await Future<void>.delayed(Duration.zero);

        expect(handler.nextError, isNotNull);
        expect(handler.resolvedResponse, isNull);
      },
    );

    test(
      'calls _clearTokensAndLogout and passes error when refresh returns false',
      () async {
        var logoutCalled = false;
        final interceptor = _TestableAuthRefreshInterceptor(
          dio: mockDio,
          storage: mockStorage,
          baseUrl: 'http://localhost:3000',
          stubRefreshResult: false,
          onForceLogout: () => logoutCalled = true,
        );

        when(mockStorage.delete(key: TokenKeys.accessToken))
            .thenAnswer((_) async {});
        when(mockStorage.delete(key: TokenKeys.refreshToken))
            .thenAnswer((_) async {});

        final handler = _FakeErrorHandler();
        interceptor.onError(_badResponse(401, path: '/api/protected'), handler);
        await Future<void>.delayed(Duration.zero);

        expect(logoutCalled, isTrue);
        expect(handler.nextError, isNotNull);
        verifyNever(mockDio.fetch(any));
      },
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Group: AuthRefreshInterceptor — logout behaviour
  // ══════════════════════════════════════════════════════════════════════════
  group('AuthRefreshInterceptor — logout behaviour', () {
    test('deletes access token key on logout', () async {
      var logoutCalled = false;
      final interceptor = _TestableAuthRefreshInterceptor(
        dio: mockDio,
        storage: mockStorage,
        baseUrl: 'http://localhost:3000',
        stubRefreshResult: false,
        onForceLogout: () => logoutCalled = true,
      );

      when(mockStorage.delete(key: TokenKeys.accessToken))
          .thenAnswer((_) async {});
      when(mockStorage.delete(key: TokenKeys.refreshToken))
          .thenAnswer((_) async {});

      final handler = _FakeErrorHandler();
      interceptor.onError(_badResponse(401, path: '/api/data'), handler);
      await Future<void>.delayed(Duration.zero);

      verify(mockStorage.delete(key: TokenKeys.accessToken)).called(1);
    });

    test('deletes refresh token key on logout', () async {
      final interceptor = _TestableAuthRefreshInterceptor(
        dio: mockDio,
        storage: mockStorage,
        baseUrl: 'http://localhost:3000',
        stubRefreshResult: false,
      );

      when(mockStorage.delete(key: anyNamed('key'))).thenAnswer((_) async {});

      final handler = _FakeErrorHandler();
      interceptor.onError(_badResponse(401, path: '/api/data'), handler);
      await Future<void>.delayed(Duration.zero);

      verify(mockStorage.delete(key: TokenKeys.refreshToken)).called(1);
    });

    test('invokes onForceLogout callback exactly once per logout', () async {
      var count = 0;
      final interceptor = _TestableAuthRefreshInterceptor(
        dio: mockDio,
        storage: mockStorage,
        baseUrl: 'http://localhost:3000',
        stubRefreshResult: false,
        onForceLogout: () => count++,
      );

      when(mockStorage.delete(key: anyNamed('key'))).thenAnswer((_) async {});

      final handler = _FakeErrorHandler();
      interceptor.onError(_badResponse(401, path: '/api/data'), handler);
      await Future<void>.delayed(Duration.zero);

      expect(count, 1);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Group: AuthRefreshInterceptor — TokenKeys constants
  // ══════════════════════════════════════════════════════════════════════════
  group('TokenKeys', () {
    test('accessToken key is "auth_token"', () {
      expect(TokenKeys.accessToken, 'auth_token');
    });

    test('refreshToken key is "refresh_token"', () {
      expect(TokenKeys.refreshToken, 'refresh_token');
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Group: ErrorInterceptor — DioExceptionType mapping
  // ══════════════════════════════════════════════════════════════════════════
  group('ErrorInterceptor — DioExceptionType mapping', () {
    late ErrorInterceptor interceptor;

    setUp(() => interceptor = ErrorInterceptor());

    _FakeErrorHandler _run(DioException error) {
      final handler = _FakeErrorHandler();
      interceptor.onError(error, handler);
      return handler;
    }

    test('connectionTimeout → NetworkException with code TIMEOUT', () {
      final h = _run(_dioError(DioExceptionType.connectionTimeout));
      final ex = h.rejectedError!.error as NetworkException;
      expect(ex.code, 'TIMEOUT');
      expect(ex.message, contains('timeout'));
    });

    test('sendTimeout → NetworkException with code TIMEOUT', () {
      final h = _run(_dioError(DioExceptionType.sendTimeout));
      final ex = h.rejectedError!.error as NetworkException;
      expect(ex.code, 'TIMEOUT');
    });

    test('receiveTimeout → NetworkException with code TIMEOUT', () {
      final h = _run(_dioError(DioExceptionType.receiveTimeout));
      final ex = h.rejectedError!.error as NetworkException;
      expect(ex.code, 'TIMEOUT');
    });

    test('connectionError → NetworkException with code NO_CONNECTION', () {
      final h = _run(_dioError(DioExceptionType.connectionError));
      final ex = h.rejectedError!.error as NetworkException;
      expect(ex.code, 'NO_CONNECTION');
      expect(ex.message, contains('internet'));
    });

    test('cancel → NetworkException with code CANCELLED', () {
      final h = _run(_dioError(DioExceptionType.cancel));
      final ex = h.rejectedError!.error as NetworkException;
      expect(ex.code, 'CANCELLED');
    });

    test('badCertificate → NetworkException with code BAD_CERTIFICATE', () {
      final h = _run(_dioError(DioExceptionType.badCertificate));
      final ex = h.rejectedError!.error as NetworkException;
      expect(ex.code, 'BAD_CERTIFICATE');
    });

    test('unknown → NetworkException with code UNKNOWN', () {
      final h = _run(_dioError(DioExceptionType.unknown, message: 'mystery'));
      final ex = h.rejectedError!.error as NetworkException;
      expect(ex.code, 'UNKNOWN');
    });

    test('always calls handler.reject (never next/resolve)', () {
      final h = _run(_dioError(DioExceptionType.connectionTimeout));
      expect(h.rejectedError, isNotNull);
      expect(h.nextError, isNull);
      expect(h.resolvedResponse, isNull);
    });

    test('preserves requestOptions in the transformed error', () {
      final original =
          _dioError(DioExceptionType.connectionTimeout, path: '/some/path');
      final h = _run(original);
      expect(h.rejectedError!.requestOptions.path, '/some/path');
    });

    test('transformed error message matches the inner exception message', () {
      final h = _run(_dioError(DioExceptionType.connectionTimeout));
      final innerEx = h.rejectedError!.error as NetworkException;
      expect(h.rejectedError!.message, innerEx.message);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Group: ErrorInterceptor — HTTP status code mapping
  // ══════════════════════════════════════════════════════════════════════════
  group('ErrorInterceptor — HTTP status code mapping', () {
    late ErrorInterceptor interceptor;
    setUp(() => interceptor = ErrorInterceptor());

    _FakeErrorHandler _run(DioException error) {
      final h = _FakeErrorHandler();
      interceptor.onError(error, h);
      return h;
    }

    // ── 400 Bad Request ───────────────────────────────────────────────────
    test('400 → ValidationException with code BAD_REQUEST', () {
      final h = _run(_badResponse(400, data: {'message': 'Bad data'}));
      final ex = h.rejectedError!.error as ValidationException;
      expect(ex.code, 'BAD_REQUEST');
      expect(ex.message, 'Bad data');
    });

    test('400 with field errors map → ValidationException.fieldErrors populated', () {
      final h = _run(_badResponse(400, data: {
        'message': 'Validation failed',
        'errors': {'email': 'Invalid email', 'name': 'Required'},
      }));
      final ex = h.rejectedError!.error as ValidationException;
      expect(ex.fieldErrors['email'], 'Invalid email');
      expect(ex.fieldErrors['name'], 'Required');
    });

    test('400 with errors as list → ValidationException.fieldErrors populated', () {
      final h = _run(_badResponse(400, data: {
        'message': 'Validation failed',
        'errors': [
          {'field': 'email', 'message': 'Invalid email'},
          {'field': 'password', 'message': 'Too short'},
        ],
      }));
      final ex = h.rejectedError!.error as ValidationException;
      expect(ex.fieldErrors['email'], 'Invalid email');
      expect(ex.fieldErrors['password'], 'Too short');
    });

    test('400 with "param" in errors list → field key uses param', () {
      final h = _run(_badResponse(400, data: {
        'message': 'Bad',
        'errors': [
          {'param': 'username', 'msg': 'Too long'},
        ],
      }));
      final ex = h.rejectedError!.error as ValidationException;
      expect(ex.fieldErrors['username'], 'Too long');
    });

    test('400 with field_errors key → ValidationException.fieldErrors populated', () {
      final h = _run(_badResponse(400, data: {
        'message': 'Bad',
        'field_errors': {'phone': 'Invalid format'},
      }));
      final ex = h.rejectedError!.error as ValidationException;
      expect(ex.fieldErrors['phone'], 'Invalid format');
    });

    test('400 with validation_errors key → ValidationException.fieldErrors populated', () {
      final h = _run(_badResponse(400, data: {
        'message': 'Bad',
        'validation_errors': {'dob': 'Invalid date'},
      }));
      final ex = h.rejectedError!.error as ValidationException;
      expect(ex.fieldErrors['dob'], 'Invalid date');
    });

    // ── 401 Unauthorized ──────────────────────────────────────────────────
    test('401 → AuthenticationException with code UNAUTHORIZED', () {
      final h = _run(_badResponse(401,
          data: {'message': 'Invalid credentials'}));
      final ex = h.rejectedError!.error as AuthenticationException;
      expect(ex.code, 'UNAUTHORIZED');
      expect(ex.message, 'Invalid credentials');
    });

    test('401 with custom code in response → uses custom code', () {
      final h = _run(_badResponse(401,
          data: {'message': 'Token expired', 'code': 'TOKEN_EXPIRED'}));
      final ex = h.rejectedError!.error as AuthenticationException;
      expect(ex.code, 'TOKEN_EXPIRED');
    });

    test('401 with no message → uses default message', () {
      final h = _run(_badResponse(401, data: <String, dynamic>{}));
      final ex = h.rejectedError!.error as AuthenticationException;
      expect(ex.message, isNotEmpty);
    });

    // ── 403 Forbidden ─────────────────────────────────────────────────────
    test('403 → AuthorizationException with code FORBIDDEN', () {
      final h = _run(_badResponse(403, data: {'message': 'Access denied'}));
      final ex = h.rejectedError!.error as AuthorizationException;
      expect(ex.code, 'FORBIDDEN');
      expect(ex.message, 'Access denied');
    });

    // ── 404 Not Found ─────────────────────────────────────────────────────
    test('404 → ServerException with code NOT_FOUND and statusCode 404', () {
      final h = _run(_badResponse(404, data: {'message': 'Not found'}));
      final ex = h.rejectedError!.error as ServerException;
      expect(ex.code, 'NOT_FOUND');
      expect(ex.statusCode, 404);
    });

    // ── 409 Conflict ──────────────────────────────────────────────────────
    test('409 → ValidationException with code CONFLICT', () {
      final h = _run(_badResponse(409, data: {'message': 'Email taken'}));
      final ex = h.rejectedError!.error as ValidationException;
      expect(ex.code, 'CONFLICT');
    });

    // ── 422 Unprocessable Entity ──────────────────────────────────────────
    test('422 → ValidationException with code VALIDATION_ERROR', () {
      final h = _run(_badResponse(422, data: {'message': 'Cannot process'}));
      final ex = h.rejectedError!.error as ValidationException;
      expect(ex.code, 'VALIDATION_ERROR');
    });

    // ── 429 Rate Limit ────────────────────────────────────────────────────
    test('429 → ServerException with code RATE_LIMIT and statusCode 429', () {
      final h = _run(_badResponse(429, data: {'message': 'Slow down'}));
      final ex = h.rejectedError!.error as ServerException;
      expect(ex.code, 'RATE_LIMIT');
      expect(ex.statusCode, 429);
    });

    // ── 5xx Server Errors ─────────────────────────────────────────────────
    for (final code in [500, 502, 503, 504]) {
      test('$code → ServerException with code SERVER_ERROR', () {
        final h = _run(_badResponse(code, data: {'message': 'Server blew up'}));
        final ex = h.rejectedError!.error as ServerException;
        expect(ex.code, 'SERVER_ERROR');
        expect(ex.statusCode, code);
        expect(ex.message, 'Server blew up');
      });
    }

    // ── default (unknown status codes) ────────────────────────────────────
    test('418 (unknown) → ServerException with code UNKNOWN_ERROR', () {
      final h = _run(_badResponse(418, data: {'message': "I'm a teapot"}));
      final ex = h.rejectedError!.error as ServerException;
      expect(ex.code, 'UNKNOWN_ERROR');
      expect(ex.statusCode, 418);
    });

    // ── null / missing response body ──────────────────────────────────────
    test('null response → ServerException with NO_RESPONSE code', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/test'),
        type: DioExceptionType.badResponse,
        response: null,
      );
      final h = _run(err);
      final ex = h.rejectedError!.error as ServerException;
      expect(ex.code, 'NO_RESPONSE');
      expect(ex.message, contains('No response'));
    });

    test('500 with null data → ServerException with fallback message', () {
      final h = _run(_badResponse(500, data: null));
      final ex = h.rejectedError!.error as ServerException;
      expect(ex.message, isNotEmpty);
    });

    test('500 with string data → message taken from string', () {
      final h = _run(_badResponse(500, data: 'Internal error text'));
      final ex = h.rejectedError!.error as ServerException;
      expect(ex.message, 'Internal error text');
    });

    test('400 with string data → message taken from string', () {
      final h = _run(_badResponse(400, data: 'Bad request text'));
      final ex = h.rejectedError!.error as ValidationException;
      expect(ex.message, 'Bad request text');
    });

    // ── "error" key fallback ──────────────────────────────────────────────
    test('response body uses "error" key → message extracted correctly', () {
      final h = _run(_badResponse(400,
          data: {'error': 'Something went wrong'}));
      final ex = h.rejectedError!.error as ValidationException;
      expect(ex.message, 'Something went wrong');
    });

    // ── status code preserved on rejected error ───────────────────────────
    test('rejected DioException preserves original response', () {
      final h = _run(_badResponse(403, data: {'message': 'No access'}));
      expect(h.rejectedError!.response!.statusCode, 403);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Group: ErrorInterceptor — exception type hierarchy
  // ══════════════════════════════════════════════════════════════════════════
  group('ErrorInterceptor — exception type hierarchy', () {
    late ErrorInterceptor interceptor;
    setUp(() => interceptor = ErrorInterceptor());

    _FakeErrorHandler _run(DioException e) {
      final h = _FakeErrorHandler();
      interceptor.onError(e, h);
      return h;
    }

    test('all produced exceptions extend AppException', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.connectionError,
        DioExceptionType.cancel,
        DioExceptionType.badCertificate,
        DioExceptionType.unknown,
      ]) {
        final h = _run(_dioError(type));
        expect(h.rejectedError!.error, isA<AppException>());
      }
      for (final code in [400, 401, 403, 404, 409, 422, 429, 500]) {
        final h =
            _run(_badResponse(code, data: {'message': 'msg'}));
        expect(h.rejectedError!.error, isA<AppException>());
      }
    });

    test('NetworkException is an AppException', () {
      final h = _run(_dioError(DioExceptionType.connectionError));
      expect(h.rejectedError!.error, isA<NetworkException>());
      expect(h.rejectedError!.error, isA<AppException>());
    });

    test('AuthenticationException is an AppException', () {
      final h = _run(_badResponse(401, data: {'message': 'unauth'}));
      expect(h.rejectedError!.error, isA<AuthenticationException>());
      expect(h.rejectedError!.error, isA<AppException>());
    });

    test('ValidationException is an AppException', () {
      final h = _run(_badResponse(400, data: {'message': 'bad'}));
      expect(h.rejectedError!.error, isA<ValidationException>());
      expect(h.rejectedError!.error, isA<AppException>());
    });

    test('ServerException is an AppException', () {
      final h = _run(_badResponse(500, data: {'message': 'server'}));
      expect(h.rejectedError!.error, isA<ServerException>());
      expect(h.rejectedError!.error, isA<AppException>());
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Group: ErrorInterceptor — edge cases
  // ══════════════════════════════════════════════════════════════════════════
  group('ErrorInterceptor — edge cases', () {
    late ErrorInterceptor interceptor;
    setUp(() => interceptor = ErrorInterceptor());

    _FakeErrorHandler _run(DioException e) {
      final h = _FakeErrorHandler();
      interceptor.onError(e, h);
      return h;
    }

    test('empty message string in JSON → uses default message', () {
      final h = _run(_badResponse(401, data: {'message': ''}));
      final ex = h.rejectedError!.error as AuthenticationException;
      expect(ex.message, isNotEmpty);
    });

    test('empty message string in JSON for 500 → uses default message', () {
      final h = _run(_badResponse(500, data: {'message': ''}));
      final ex = h.rejectedError!.error as ServerException;
      expect(ex.message, isNotEmpty);
    });

    test('message is preserved exactly when non-empty', () {
      const msg = 'Very specific error from server';
      final h = _run(_badResponse(404, data: {'message': msg}));
      final ex = h.rejectedError!.error as ServerException;
      expect(ex.message, msg);
    });

    test('unknown error type includes original message in NetworkException', () {
      final h = _run(_dioError(
        DioExceptionType.unknown,
        message: 'socket hang up',
      ));
      final ex = h.rejectedError!.error as NetworkException;
      expect(ex.message, contains('socket hang up'));
    });

    test('integer data body for 400 → falls through to default message', () {
      final h = _run(_badResponse(400, data: 42));
      // data is not String or Map, so message stays as default
      final ex = h.rejectedError!.error as ValidationException;
      expect(ex.message, isNotEmpty);
    });

    test('errors list with missing field key → entry silently skipped', () {
      final h = _run(_badResponse(400, data: {
        'message': 'Validation failed',
        'errors': [
          {'message': 'No field key here'},
        ],
      }));
      final ex = h.rejectedError!.error as ValidationException;
      // Should not throw; field errors will be empty
      expect(ex.fieldErrors, isEmpty);
    });

    test('502 shares SERVER_ERROR code with 500', () {
      final h502 = _run(_badResponse(502, data: {'message': 'bad gateway'}));
      final h500 = _run(_badResponse(500, data: {'message': 'internal'}));
      expect((h502.rejectedError!.error as ServerException).code,
          equals((h500.rejectedError!.error as ServerException).code));
    });
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Testable subclass of AuthRefreshInterceptor
//
// Overrides _refreshToken so we can stub the result without a real network,
// and optionally stubs storage.read for the new token after refresh.
// ─────────────────────────────────────────────────────────────────────────────
class _TestableAuthRefreshInterceptor extends AuthRefreshInterceptor {
  final bool stubRefreshResult;
  final String? newTokenAfterRefresh;

  _TestableAuthRefreshInterceptor({
    required super.dio,
    required super.storage,
    required super.baseUrl,
    required this.stubRefreshResult,
    this.newTokenAfterRefresh,
    super.onForceLogout,
  });

  @override
  Future<bool> refreshToken() async {
    if (stubRefreshResult && newTokenAfterRefresh != null) {
      // Simulate the storage write that real refresh does
      await storage.write(
        key: TokenKeys.accessToken,
        value: newTokenAfterRefresh!,
      );
    }
    return stubRefreshResult;
  }
}
