import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:felo_na/core/constants/enums.dart';
import 'package:felo_na/core/network/auth_interceptor.dart';
import 'package:felo_na/core/network/web_storage.dart';
import 'package:felo_na/features/auth/data/models/user_model.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_event.dart';
import 'package:felo_na/features/auth/presentation/bloc/auth_state.dart';

@GenerateMocks([Dio, AppStorage])
import 'auth_bloc_test.mocks.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared test fixtures
// ─────────────────────────────────────────────────────────────────────────────

final _tUser = UserModel(
  id: 'user-123',
  fullName: 'Alice Test',
  email: 'alice@example.com',
  role: UserRole.normalUser,
  phoneNumber: '+251900000001',
  profilePictureUrl: null,
  ecoPoints: 50,
  createdAt: DateTime(2024, 1, 15),
);

final _tUserJson = {
  'id': 'user-123',
  'full_name': 'Alice Test',
  'email': 'alice@example.com',
  'role': 'normal_user',
  'phone_number': '+251900000001',
  'profile_picture_url': null,
  'eco_points': 50,
  'created_at': '2024-01-15T00:00:00.000',
};

const _tAccessToken = 'access_token_abc123';
const _tRefreshToken = 'refresh_token_xyz789';

/// Builds a fake Dio [Response] without a real HTTP call.
Response<dynamic> _fakeResponse({
  required int statusCode,
  required dynamic data,
  String path = '/test',
}) {
  // Ensure Map data is always Map<String, dynamic> to match production parsing
  dynamic normalizedData = data;
  if (data is Map && data is! Map<String, dynamic>) {
    normalizedData = Map<String, dynamic>.from(data as Map);
  }
  return Response(
    requestOptions: RequestOptions(path: path),
    statusCode: statusCode,
    data: normalizedData,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Test suite
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late MockDio mockDio;
  late MockAppStorage mockStorage;

  setUp(() {
    mockDio = MockDio();
    mockStorage = MockAppStorage();

    // Dio requires BaseOptions to be readable; provide a sensible default.
    when(mockDio.options).thenReturn(
      BaseOptions(
        baseUrl: 'http://localhost:3000',
        headers: {'Content-Type': 'application/json'},
        validateStatus: (s) => s != null && s < 500,
      ),
    );
  });

  // Helper: create the bloc under test
  AuthBloc _bloc() => AuthBloc(dio: mockDio, storage: mockStorage);

  // ══════════════════════════════════════════════════════════════════════════
  // Initial state
  // ══════════════════════════════════════════════════════════════════════════
  group('AuthBloc — initial state', () {
    test('initial state is AuthInitial', () {
      expect(_bloc().state, const AuthInitial());
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // AuthCheckRequested
  // ══════════════════════════════════════════════════════════════════════════
  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when no token stored',
      build: _bloc,
      setUp: () {
        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => null);
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => const [AuthLoading(), Unauthenticated()],
      verify: (_) {
        verify(mockStorage.read(key: TokenKeys.accessToken)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when stored token is empty string',
      build: _bloc,
      setUp: () {
        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => '');
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => const [AuthLoading(), Unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when token is valid (200 from /auth/me)',
      build: _bloc,
      setUp: () {
        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => _tAccessToken);
        when(mockDio.get(
          '/auth/me',
          options: anyNamed('options'),
        )).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 200,
            data: {'user': _tUserJson},
            path: '/auth/me',
          ),
        );
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthLoading(), Authenticated(user: _tUser)],
      verify: (_) {
        verify(mockDio.get('/auth/me', options: anyNamed('options'))).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when /auth/me returns data as JSON string',
      build: _bloc,
      setUp: () {
        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => _tAccessToken);
        when(mockDio.get('/auth/me', options: anyNamed('options'))).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 200,
            data: jsonEncode({'user': _tUserJson}),
            path: '/auth/me',
          ),
        );
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthLoading(), Authenticated(user: _tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] on 401 when refresh token is also absent',
      build: _bloc,
      setUp: () {
        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => _tAccessToken);
        when(mockDio.get('/auth/me', options: anyNamed('options'))).thenAnswer(
          (_) async => _fakeResponse(statusCode: 401, data: {}, path: '/auth/me'),
        );
        when(mockStorage.read(key: TokenKeys.refreshToken))
            .thenAnswer((_) async => null);
        when(mockStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => const [AuthLoading(), Unauthenticated()],
      verify: (_) {
        verify(mockStorage.delete(key: TokenKeys.accessToken)).called(1);
        verify(mockStorage.delete(key: TokenKeys.refreshToken)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when /auth/me throws (network error)',
      build: _bloc,
      setUp: () {
        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => _tAccessToken);
        when(mockDio.get('/auth/me', options: anyNamed('options'))).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/auth/me'),
            type: DioExceptionType.connectionError,
          ),
        );
        when(mockStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => const [AuthLoading(), Unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when /auth/me returns non-200/401 status',
      build: _bloc,
      setUp: () {
        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => _tAccessToken);
        when(mockDio.get('/auth/me', options: anyNamed('options'))).thenAnswer(
          (_) async => _fakeResponse(statusCode: 403, data: {}, path: '/auth/me'),
        );
        when(mockStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => const [AuthLoading(), Unauthenticated()],
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Token refresh path (inside AuthCheck) — using testable subclass
  // ══════════════════════════════════════════════════════════════════════════
  group('AuthCheckRequested — token refresh path', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when refresh returns false (no refresh token)',
      build: () => _TestableAuthBloc(
        dio: mockDio,
        storage: mockStorage,
        stubRefreshResult: false,
      ),
      setUp: () {
        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => 'expired_token');
        when(mockDio.get('/auth/me', options: anyNamed('options')))
            .thenAnswer((_) async =>
                _fakeResponse(statusCode: 401, data: <String, dynamic>{}, path: '/auth/me'));
        when(mockStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => const [AuthLoading(), Unauthenticated()],
      verify: (_) {
        verify(mockStorage.delete(key: TokenKeys.accessToken)).called(1);
        verify(mockStorage.delete(key: TokenKeys.refreshToken)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when refresh succeeds and retry returns 200',
      build: () => _TestableAuthBloc(
        dio: mockDio,
        storage: mockStorage,
        stubRefreshResult: true,
      ),
      setUp: () {
        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => 'new_access_token');
        // First call: 401, subsequent retry call: 200
        var callCount = 0;
        when(mockDio.get('/auth/me', options: anyNamed('options')))
            .thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            return _fakeResponse(statusCode: 401, data: <String, dynamic>{}, path: '/auth/me');
          }
          return _fakeResponse(
              statusCode: 200, data: <String, dynamic>{'user': _tUserJson}, path: '/auth/me');
        });
        when(mockStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthLoading(), Authenticated(user: _tUser)],
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // LoginRequested
  // ══════════════════════════════════════════════════════════════════════════
  group('LoginRequested', () {
    const tEvent = LoginRequested(
      email: 'alice@example.com',
      password: 'password123',
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] on successful login (200 + token)',
      build: _bloc,
      setUp: () {
        when(mockDio.post('/auth/login', data: anyNamed('data'))).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 200,
            data: {
              'token': _tAccessToken,
              'refreshToken': _tRefreshToken,
              'user': _tUserJson,
            },
            path: '/auth/login',
          ),
        );
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [const AuthLoading(), Authenticated(user: _tUser)],
      verify: (_) {
        verify(mockDio.post('/auth/login', data: anyNamed('data'))).called(1);
        verify(mockStorage.write(
          key: TokenKeys.accessToken,
          value: _tAccessToken,
        )).called(1);
        verify(mockStorage.write(
          key: TokenKeys.refreshToken,
          value: _tRefreshToken,
        )).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'stores access token but skips refresh token when absent in response',
      build: _bloc,
      setUp: () {
        when(mockDio.post('/auth/login', data: anyNamed('data'))).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 200,
            data: {'token': _tAccessToken, 'user': _tUserJson},
            path: '/auth/login',
          ),
        );
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [const AuthLoading(), Authenticated(user: _tUser)],
      verify: (_) {
        verify(mockStorage.write(
                key: TokenKeys.accessToken, value: _tAccessToken))
            .called(1);
        verifyNever(mockStorage.write(
            key: TokenKeys.refreshToken, value: anyNamed('value')));
      },
    );

    blocTest<AuthBloc, AuthState>(
      'accepts accessToken key variant in login response',
      build: _bloc,
      setUp: () {
        when(mockDio.post('/auth/login', data: anyNamed('data'))).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 200,
            data: {'accessToken': _tAccessToken, 'user': _tUserJson},
            path: '/auth/login',
          ),
        );
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [const AuthLoading(), Authenticated(user: _tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'accepts access_token key variant in login response',
      build: _bloc,
      setUp: () {
        when(mockDio.post('/auth/login', data: anyNamed('data'))).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 200,
            data: {'access_token': _tAccessToken, 'user': _tUserJson},
            path: '/auth/login',
          ),
        );
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [const AuthLoading(), Authenticated(user: _tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when 200 but no token in response',
      build: _bloc,
      setUp: () {
        when(mockDio.post('/auth/login', data: anyNamed('data'))).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 200,
            data: {'user': _tUserJson}, // no token field
            path: '/auth/login',
          ),
        );
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        const AuthLoading(),
        const AuthError(message: 'No token received from server'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, EmailVerificationRequired] when 403 with requires_verification',
      build: _bloc,
      setUp: () {
        when(mockDio.post('/auth/login', data: anyNamed('data'))).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 403,
            data: {
              'requires_verification': true,
              'email': 'alice@example.com',
            },
            path: '/auth/login',
          ),
        );
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        const AuthLoading(),
        const EmailVerificationRequired(email: 'alice@example.com'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, EmailVerificationRequired] using event email when response email absent',
      build: _bloc,
      setUp: () {
        when(mockDio.post('/auth/login', data: anyNamed('data'))).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 403,
            data: {'requires_verification': true},
            path: '/auth/login',
          ),
        );
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        const AuthLoading(),
        const EmailVerificationRequired(email: 'alice@example.com'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login returns 401',
      build: _bloc,
      setUp: () {
        when(mockDio.post('/auth/login', data: anyNamed('data'))).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 401,
            data: {'message': 'Invalid credentials'},
            path: '/auth/login',
          ),
        );
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        const AuthLoading(),
        const AuthError(message: 'Invalid credentials'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] using error field fallback',
      build: _bloc,
      setUp: () {
        when(mockDio.post('/auth/login', data: anyNamed('data'))).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 401,
            data: {'error': 'Unauthorized'},
            path: '/auth/login',
          ),
        );
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        const AuthLoading(),
        const AuthError(message: 'Unauthorized'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] with default message when no message/error fields',
      build: _bloc,
      setUp: () {
        when(mockDio.post('/auth/login', data: anyNamed('data'))).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 401,
            data: <String, dynamic>{},
            path: '/auth/login',
          ),
        );
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        const AuthLoading(),
        const AuthError(message: 'Login failed'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when Dio throws (network error)',
      build: _bloc,
      setUp: () {
        when(mockDio.post('/auth/login', data: anyNamed('data'))).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/auth/login'),
            type: DioExceptionType.connectionError,
          ),
        );
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        const AuthLoading(),
        isA<AuthError>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'parses JSON string response body correctly',
      build: _bloc,
      setUp: () {
        when(mockDio.post('/auth/login', data: anyNamed('data'))).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 200,
            data: jsonEncode({
              'token': _tAccessToken,
              'user': _tUserJson,
            }),
            path: '/auth/login',
          ),
        );
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [const AuthLoading(), Authenticated(user: _tUser)],
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // RegisterRequested
  // ══════════════════════════════════════════════════════════════════════════
  group('RegisterRequested', () {
    final tEvent = RegisterRequested(
      fullName: 'Alice Test',
      email: 'alice@example.com',
      password: 'password123',
      role: UserRole.normalUser,
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, EmailVerificationRequired] on 201',
      build: _bloc,
      setUp: () {
        when(mockDio.post('/auth/register', data: anyNamed('data'))).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 201,
            data: {'message': 'Check your email'},
            path: '/auth/register',
          ),
        );
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        const AuthLoading(),
        const EmailVerificationRequired(email: 'alice@example.com'),
      ],
      verify: (_) {
        verify(mockDio.post('/auth/register', data: anyNamed('data'))).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, EmailVerificationRequired] on 200',
      build: _bloc,
      setUp: () {
        when(mockDio.post('/auth/register', data: anyNamed('data'))).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 200,
            data: {},
            path: '/auth/register',
          ),
        );
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        const AuthLoading(),
        const EmailVerificationRequired(email: 'alice@example.com'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'sends normal_user role string for normalUser enum',
      build: _bloc,
      setUp: () {
        when(mockDio.post('/auth/register', data: anyNamed('data'))).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 201,
            data: {},
            path: '/auth/register',
          ),
        );
      },
      act: (bloc) => bloc.add(tEvent),
      verify: (_) {
        final captured = verify(
          mockDio.post('/auth/register', data: captureAnyNamed('data')),
        ).captured;
        final sentData = captured.first as Map<String, dynamic>;
        expect(sentData['role'], 'normal_user');
      },
    );

    blocTest<AuthBloc, AuthState>(
      'sends non-normalUser role name as-is',
      build: _bloc,
      setUp: () {
        when(mockDio.post('/auth/register', data: anyNamed('data'))).thenAnswer(
          (_) async =>
              _fakeResponse(statusCode: 201, data: {}, path: '/auth/register'),
        );
      },
      act: (bloc) => bloc.add(RegisterRequested(
        fullName: 'Bob',
        email: 'bob@example.com',
        password: 'pass',
        role: UserRole.buyer,
      )),
      verify: (_) {
        final captured = verify(
          mockDio.post('/auth/register', data: captureAnyNamed('data')),
        ).captured;
        final sentData = captured.first as Map<String, dynamic>;
        expect(sentData['role'], 'buyer');
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when server returns error status',
      build: _bloc,
      setUp: () {
        when(mockDio.post('/auth/register', data: anyNamed('data'))).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 409,
            data: {'error': 'Email already exists'},
            path: '/auth/register',
          ),
        );
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        const AuthLoading(),
        const AuthError(message: 'Email already exists'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] with default message when no error field',
      build: _bloc,
      setUp: () {
        when(mockDio.post('/auth/register', data: anyNamed('data'))).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 400,
            data: <String, dynamic>{},
            path: '/auth/register',
          ),
        );
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        const AuthLoading(),
        const AuthError(message: 'Registration failed'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when Dio throws',
      build: _bloc,
      setUp: () {
        when(mockDio.post('/auth/register', data: anyNamed('data'))).thenThrow(
          Exception('Network unreachable'),
        );
      },
      act: (bloc) => bloc.add(tEvent),
      expect: () => [
        const AuthLoading(),
        isA<AuthError>(),
      ],
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // VerificationCompleted
  // ══════════════════════════════════════════════════════════════════════════
  group('VerificationCompleted', () {
    blocTest<AuthBloc, AuthState>(
      'emits [Authenticated] and stores access + refresh tokens',
      build: _bloc,
      setUp: () {
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(VerificationCompleted(
        token: _tAccessToken,
        refreshToken: _tRefreshToken,
        userJson: _tUserJson,
      )),
      expect: () => [Authenticated(user: _tUser)],
      verify: (_) {
        verify(mockStorage.write(
          key: TokenKeys.accessToken,
          value: _tAccessToken,
        )).called(1);
        verify(mockStorage.write(
          key: TokenKeys.refreshToken,
          value: _tRefreshToken,
        )).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Authenticated] and does NOT write refresh token when absent',
      build: _bloc,
      setUp: () {
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(VerificationCompleted(
        token: _tAccessToken,
        userJson: _tUserJson, // no refreshToken
      )),
      expect: () => [Authenticated(user: _tUser)],
      verify: (_) {
        verify(mockStorage.write(
          key: TokenKeys.accessToken,
          value: _tAccessToken,
        )).called(1);
        verifyNever(mockStorage.write(
          key: TokenKeys.refreshToken,
          value: anyNamed('value'),
        ));
      },
    );

    blocTest<AuthBloc, AuthState>(
      'correctly parses userJson into User entity',
      build: _bloc,
      setUp: () {
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(VerificationCompleted(
        token: _tAccessToken,
        userJson: _tUserJson,
      )),
      expect: () => [
        predicate<AuthState>((s) =>
            s is Authenticated &&
            s.user.email == 'alice@example.com' &&
            s.user.role == UserRole.normalUser),
      ],
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // LogoutRequested
  // ══════════════════════════════════════════════════════════════════════════
  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] and clears both token keys',
      build: _bloc,
      setUp: () {
        when(mockStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => const [AuthLoading(), Unauthenticated()],
      verify: (_) {
        verify(mockStorage.delete(key: TokenKeys.accessToken)).called(1);
        verify(mockStorage.delete(key: TokenKeys.refreshToken)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'always emits Unauthenticated regardless of current state',
      build: () {
        final bloc = _bloc();
        // Seed the bloc with Authenticated state by emitting it manually
        // via a VerificationCompleted event
        return bloc;
      },
      setUp: () {
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async {});
        when(mockStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async {});
      },
      act: (bloc) async {
        // First authenticate
        bloc.add(VerificationCompleted(
          token: _tAccessToken,
          userJson: _tUserJson,
        ));
        await Future<void>.delayed(Duration.zero);
        // Then logout
        bloc.add(const LogoutRequested());
      },
      expect: () => [
        Authenticated(user: _tUser), // from VerificationCompleted
        const AuthLoading(),
        const Unauthenticated(),
      ],
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // UpdateProfileRequested
  // ══════════════════════════════════════════════════════════════════════════
  group('UpdateProfileRequested', () {
    final tUpdatedUser = UserModel(
      id: _tUser.id,
      fullName: 'Alice Updated',
      email: _tUser.email,
      role: _tUser.role,
      phoneNumber: _tUser.phoneNumber,
      profilePictureUrl: _tUser.profilePictureUrl,
      ecoPoints: _tUser.ecoPoints,
      createdAt: _tUser.createdAt,
    );
    final tUpdatedUserJson = {
      ..._tUserJson,
      'full_name': 'Alice Updated',
    };

    // Helper: seed the bloc into Authenticated state first
    void _seedAuthenticated(MockAppStorage storage) {
      when(storage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async {});
    }

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, ProfileUpdated, Authenticated] on successful update',
      build: _bloc,
      setUp: () {
        _seedAuthenticated(mockStorage);
        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => _tAccessToken);
        when(mockDio.put(
          any,
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 200,
            data: {'user': tUpdatedUserJson},
            path: '/auth/profile/user-123',
          ),
        );
      },
      seed: () => Authenticated(user: _tUser),
      act: (bloc) => bloc.add(const UpdateProfileRequested(
        fullName: 'Alice Updated',
      )),
      expect: () => [
        const AuthLoading(),
        ProfileUpdated(user: tUpdatedUser),
        Authenticated(user: tUpdatedUser),
      ],
      verify: (_) {
        verify(mockStorage.read(key: TokenKeys.accessToken)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'does nothing when current state is not Authenticated',
      build: _bloc,
      seed: () => const Unauthenticated(),
      act: (bloc) =>
          bloc.add(const UpdateProfileRequested(fullName: 'New Name')),
      expect: () => [],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError, Authenticated] when PUT returns non-200',
      build: _bloc,
      setUp: () {
        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => _tAccessToken);
        when(mockDio.put(
          any,
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer(
          (_) async =>
              _fakeResponse(statusCode: 400, data: {}, path: '/auth/profile/user-123'),
        );
      },
      seed: () => Authenticated(user: _tUser),
      act: (bloc) =>
          bloc.add(const UpdateProfileRequested(fullName: 'Bad Name')),
      expect: () => [
        const AuthLoading(),
        const AuthError(message: 'Profile update failed.'),
        Authenticated(user: _tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError, Authenticated] when Dio throws',
      build: _bloc,
      setUp: () {
        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => _tAccessToken);
        when(mockDio.put(
          any,
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenThrow(Exception('Connection refused'));
      },
      seed: () => Authenticated(user: _tUser),
      act: (bloc) => bloc.add(const UpdateProfileRequested(fullName: 'X')),
      expect: () => [
        const AuthLoading(),
        const AuthError(message: 'Profile update failed.'),
        Authenticated(user: _tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'sends fullName in PUT body when provided',
      build: _bloc,
      setUp: () {
        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => _tAccessToken);
        when(mockDio.put(
          any,
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 200,
            data: {'user': tUpdatedUserJson},
            path: '/auth/profile/user-123',
          ),
        );
      },
      seed: () => Authenticated(user: _tUser),
      act: (bloc) => bloc.add(const UpdateProfileRequested(fullName: 'Alice Updated')),
      verify: (_) {
        final captured = verify(mockDio.put(
          any,
          data: captureAnyNamed('data'),
          options: anyNamed('options'),
        )).captured;
        final body = captured.first as Map<String, dynamic>;
        expect(body['full_name'], 'Alice Updated');
        expect(body.containsKey('phone_number'), isFalse);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'sends phoneNumber in PUT body when provided',
      build: _bloc,
      setUp: () {
        final userWithPhone = _tUser.copyWith(phoneNumber: '+251900000099');
        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => _tAccessToken);
        when(mockDio.put(
          any,
          data: anyNamed('data'),
          options: anyNamed('options'),
        )).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 200,
            data: {
              'user': {..._tUserJson, 'phone_number': '+251900000099'},
            },
            path: '/auth/profile/user-123',
          ),
        );
      },
      seed: () => Authenticated(user: _tUser),
      act: (bloc) =>
          bloc.add(const UpdateProfileRequested(phoneNumber: '+251900000099')),
      verify: (_) {
        final captured = verify(mockDio.put(
          any,
          data: captureAnyNamed('data'),
          options: anyNamed('options'),
        )).captured;
        final body = captured.first as Map<String, dynamic>;
        expect(body['phone_number'], '+251900000099');
        expect(body.containsKey('full_name'), isFalse);
      },
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // UploadProfilePictureRequested
  // ══════════════════════════════════════════════════════════════════════════
  group('UploadProfilePictureRequested', () {
    // Note: _onUploadPicture creates an internal Dio, so we can't intercept
    // the actual HTTP call. We test the observable state transitions and
    // the error / no-op paths.

    blocTest<AuthBloc, AuthState>(
      'does nothing when current state is not Authenticated',
      build: _bloc,
      seed: () => const Unauthenticated(),
      act: (bloc) => bloc.add(
        const UploadProfilePictureRequested(imagePath: '/tmp/photo.jpg'),
      ),
      expect: () => [],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [ProfilePictureUploading, AuthError, Authenticated] when upload fails',
      build: _bloc,
      setUp: () {
        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => _tAccessToken);
        // The internal uploadDio.post will fail (no server / file not found)
        // → catches exception and emits AuthError then Authenticated
      },
      seed: () => Authenticated(user: _tUser),
      act: (bloc) => bloc.add(
        const UploadProfilePictureRequested(imagePath: '/tmp/photo.jpg'),
      ),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const ProfilePictureUploading(),
        isA<AuthError>(),
        Authenticated(user: _tUser),
      ],
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // DeleteAccountRequested
  // ══════════════════════════════════════════════════════════════════════════
  group('DeleteAccountRequested', () {
    blocTest<AuthBloc, AuthState>(
      'does nothing when current state is not Authenticated',
      build: _bloc,
      seed: () => const Unauthenticated(),
      act: (bloc) => bloc.add(const DeleteAccountRequested()),
      expect: () => [],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AccountDeleted, Unauthenticated] on 200',
      build: _bloc,
      setUp: () {
        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => _tAccessToken);
        when(mockDio.delete(
          '/users/account',
          options: anyNamed('options'),
        )).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 200,
            data: {'message': 'Account deleted'},
            path: '/users/account',
          ),
        );
        when(mockStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async {});
      },
      seed: () => Authenticated(user: _tUser),
      act: (bloc) => bloc.add(const DeleteAccountRequested()),
      expect: () => const [
        AuthLoading(),
        AccountDeleted(),
        Unauthenticated(),
      ],
      verify: (_) {
        verify(mockStorage.delete(key: TokenKeys.accessToken)).called(1);
        verify(mockStorage.delete(key: TokenKeys.refreshToken)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AccountDeleted, Unauthenticated] on 204',
      build: _bloc,
      setUp: () {
        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => _tAccessToken);
        when(mockDio.delete(
          '/users/account',
          options: anyNamed('options'),
        )).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 204,
            data: null,
            path: '/users/account',
          ),
        );
        when(mockStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async {});
      },
      seed: () => Authenticated(user: _tUser),
      act: (bloc) => bloc.add(const DeleteAccountRequested()),
      expect: () => const [
        AuthLoading(),
        AccountDeleted(),
        Unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError, Authenticated] when delete returns non-200/204',
      build: _bloc,
      setUp: () {
        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => _tAccessToken);
        when(mockDio.delete(
          '/users/account',
          options: anyNamed('options'),
        )).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 400,
            data: {'message': 'Cannot delete account'},
            path: '/users/account',
          ),
        );
      },
      seed: () => Authenticated(user: _tUser),
      act: (bloc) => bloc.add(const DeleteAccountRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthError(message: 'Cannot delete account'),
        Authenticated(user: _tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError, Authenticated] with default message on empty response body',
      build: _bloc,
      setUp: () {
        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => _tAccessToken);
        when(mockDio.delete(
          '/users/account',
          options: anyNamed('options'),
        )).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 400,
            data: <String, dynamic>{},
            path: '/users/account',
          ),
        );
      },
      seed: () => Authenticated(user: _tUser),
      act: (bloc) => bloc.add(const DeleteAccountRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthError(message: 'Account deletion failed'),
        Authenticated(user: _tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError, Authenticated] when DELETE throws',
      build: _bloc,
      setUp: () {
        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => _tAccessToken);
        when(mockDio.delete(
          '/users/account',
          options: anyNamed('options'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/users/account'),
          type: DioExceptionType.connectionError,
        ));
      },
      seed: () => Authenticated(user: _tUser),
      act: (bloc) => bloc.add(const DeleteAccountRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthError(message: 'Account deletion failed. Please try again.'),
        Authenticated(user: _tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'clears tokens from storage after successful account deletion',
      build: _bloc,
      setUp: () {
        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => _tAccessToken);
        when(mockDio.delete(
          '/users/account',
          options: anyNamed('options'),
        )).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 200,
            data: {},
            path: '/users/account',
          ),
        );
        when(mockStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async {});
      },
      seed: () => Authenticated(user: _tUser),
      act: (bloc) => bloc.add(const DeleteAccountRequested()),
      verify: (_) {
        verify(mockStorage.delete(key: TokenKeys.accessToken)).called(1);
        verify(mockStorage.delete(key: TokenKeys.refreshToken)).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'parses JSON string body on non-200 delete response',
      build: _bloc,
      setUp: () {
        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => _tAccessToken);
        when(mockDio.delete(
          '/users/account',
          options: anyNamed('options'),
        )).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 400,
            data: jsonEncode({'message': 'Cannot delete'}),
            path: '/users/account',
          ),
        );
      },
      seed: () => Authenticated(user: _tUser),
      act: (bloc) => bloc.add(const DeleteAccountRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthError(message: 'Cannot delete'),
        Authenticated(user: _tUser),
      ],
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // Token persistence verification
  // ══════════════════════════════════════════════════════════════════════════
  group('Token persistence behaviour', () {
    blocTest<AuthBloc, AuthState>(
      'login: writes access token to storage with correct key',
      build: _bloc,
      setUp: () {
        when(mockDio.post('/auth/login', data: anyNamed('data'))).thenAnswer(
          (_) async => _fakeResponse(
            statusCode: 200,
            data: {'token': _tAccessToken, 'user': _tUserJson},
            path: '/auth/login',
          ),
        );
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(const LoginRequested(
        email: 'alice@example.com',
        password: 'pass',
      )),
      verify: (_) {
        verify(mockStorage.write(
          key: 'auth_token', // TokenKeys.accessToken
          value: _tAccessToken,
        )).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'logout: deletes auth_token and refresh_token keys',
      build: _bloc,
      setUp: () {
        when(mockStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      verify: (_) {
        verify(mockStorage.delete(key: 'auth_token')).called(1);
        verify(mockStorage.delete(key: 'refresh_token')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'auth check: reads auth_token from storage first',
      build: _bloc,
      setUp: () {
        when(mockStorage.read(key: TokenKeys.accessToken))
            .thenAnswer((_) async => null);
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      verify: (_) {
        verify(mockStorage.read(key: 'auth_token')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'verification: stores refresh_token with correct key value',
      build: _bloc,
      setUp: () {
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(VerificationCompleted(
        token: _tAccessToken,
        refreshToken: 'my_refresh_token',
        userJson: _tUserJson,
      )),
      verify: (_) {
        verify(mockStorage.write(
          key: 'refresh_token',
          value: 'my_refresh_token',
        )).called(1);
      },
    );
  });

  // ══════════════════════════════════════════════════════════════════════════
  // State equality
  // ══════════════════════════════════════════════════════════════════════════
  group('AuthState equality', () {
    test('AuthInitial equals AuthInitial', () {
      expect(const AuthInitial(), const AuthInitial());
    });

    test('AuthLoading equals AuthLoading', () {
      expect(const AuthLoading(), const AuthLoading());
    });

    test('Unauthenticated equals Unauthenticated', () {
      expect(const Unauthenticated(), const Unauthenticated());
    });

    test('Authenticated with same user equals Authenticated', () {
      expect(
        Authenticated(user: _tUser),
        Authenticated(user: _tUser),
      );
    });

    test('Authenticated with different user is not equal', () {
      final otherUser = _tUser.copyWith(id: 'other-id');
      expect(Authenticated(user: _tUser), isNot(Authenticated(user: otherUser)));
    });

    test('AuthError with same message equals AuthError', () {
      expect(
        const AuthError(message: 'err'),
        const AuthError(message: 'err'),
      );
    });

    test('AuthError with different message is not equal', () {
      expect(
        const AuthError(message: 'err1'),
        isNot(const AuthError(message: 'err2')),
      );
    });

    test('EmailVerificationRequired equals with same email', () {
      expect(
        const EmailVerificationRequired(email: 'a@b.com'),
        const EmailVerificationRequired(email: 'a@b.com'),
      );
    });

    test('ProfileUpdated equals with same user', () {
      expect(ProfileUpdated(user: _tUser), ProfileUpdated(user: _tUser));
    });

    test('ProfilePictureUploading equals ProfilePictureUploading', () {
      expect(
          const ProfilePictureUploading(), const ProfilePictureUploading());
    });

    test('ProfilePictureUploaded equals with same user', () {
      expect(
        ProfilePictureUploaded(user: _tUser),
        ProfilePictureUploaded(user: _tUser),
      );
    });

    test('AccountDeleted equals AccountDeleted', () {
      expect(const AccountDeleted(), const AccountDeleted());
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // AuthEvent equality
  // ══════════════════════════════════════════════════════════════════════════
  group('AuthEvent equality', () {
    test('AuthCheckRequested equals AuthCheckRequested', () {
      expect(const AuthCheckRequested(), const AuthCheckRequested());
    });

    test('LoginRequested equals with same credentials', () {
      expect(
        const LoginRequested(email: 'a@b.com', password: 'p'),
        const LoginRequested(email: 'a@b.com', password: 'p'),
      );
    });

    test('LoginRequested not equal with different password', () {
      expect(
        const LoginRequested(email: 'a@b.com', password: 'p1'),
        isNot(const LoginRequested(email: 'a@b.com', password: 'p2')),
      );
    });

    test('RegisterRequested equals with same fields', () {
      expect(
        RegisterRequested(
          fullName: 'A',
          email: 'a@b.com',
          password: 'p',
          role: UserRole.buyer,
        ),
        RegisterRequested(
          fullName: 'A',
          email: 'a@b.com',
          password: 'p',
          role: UserRole.buyer,
        ),
      );
    });

    test('LogoutRequested equals LogoutRequested', () {
      expect(const LogoutRequested(), const LogoutRequested());
    });

    test('UpdateProfileRequested equals with same fields', () {
      expect(
        const UpdateProfileRequested(fullName: 'X', phoneNumber: '+1'),
        const UpdateProfileRequested(fullName: 'X', phoneNumber: '+1'),
      );
    });

    test('UploadProfilePictureRequested equals with same imagePath', () {
      expect(
        const UploadProfilePictureRequested(imagePath: '/tmp/a.jpg'),
        const UploadProfilePictureRequested(imagePath: '/tmp/a.jpg'),
      );
    });

    test('DeleteAccountRequested equals DeleteAccountRequested', () {
      expect(const DeleteAccountRequested(), const DeleteAccountRequested());
    });

    test('VerificationCompleted equals with same fields', () {
      expect(
        VerificationCompleted(
          token: 'tok',
          refreshToken: 'ref',
          userJson: {'id': '1'},
        ),
        VerificationCompleted(
          token: 'tok',
          refreshToken: 'ref',
          userJson: {'id': '1'},
        ),
      );
    });
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Testable subclass of AuthBloc
//
// Overrides tryRefreshToken() so refresh-path tests are fast and network-free.
// ─────────────────────────────────────────────────────────────────────────────
class _TestableAuthBloc extends AuthBloc {
  final bool stubRefreshResult;

  _TestableAuthBloc({
    required Dio dio,
    required AppStorage storage,
    required this.stubRefreshResult,
  }) : super(dio: dio, storage: storage);

  @override
  Future<bool> tryRefreshToken() async => stubRefreshResult;
}
