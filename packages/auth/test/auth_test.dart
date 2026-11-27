import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storage/storage.dart';

class _FakeApi implements AuthApi {
  int refreshCalls = 0;
  AppException? refreshError;
  int logoutCalls = 0;

  @override
  Future<AuthTokens> login(LoginCredentials c) async => switch (c) {
    PasswordCredentials(password: 'ok') => AuthTokens(
      accessToken: 'a1',
      refreshToken: 'r1',
      expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
    ),
    _ => throw const UnauthorizedException('wrong'),
  };

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    refreshCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (refreshError case final e?) throw e;
    return AuthTokens(
      accessToken: 'a${refreshCalls + 1}',
      expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<void> logout({String? refreshToken}) async => logoutCalls++;

  @override
  Future<OtpChallenge> requestOtp(String phone) async =>
      const OtpChallenge(requestId: 'req');
}

void main() {
  late _FakeApi api;
  late SecureTokenStorage storage;
  late AuthManager auth;

  setUp(() {
    api = _FakeApi();
    FlutterSecureStorage.setMockInitialValues({});
    storage = SecureTokenStorage(SecureStorageService());
    auth = AuthManager(api: api, storage: storage);
  });

  tearDown(() => auth.dispose());

  test('restore without tokens → Unauthenticated(initial)', () async {
    expect(await auth.restoreSession(), const Unauthenticated());
    expect(await auth.accessToken, isNull);
  });

  test('login persists tokens and emits Authenticated', () async {
    await auth.restoreSession();
    final emitted = <AuthStatus>[];
    final sub = auth.status.listen(emitted.add);
    final result = await auth.login(
      const PasswordCredentials(username: 'u', password: 'ok'),
    );
    expect(result.isSuccess, isTrue);
    expect(await auth.accessToken, 'a1');
    expect((await storage.read())!.refreshToken, 'r1');
    await Future<void>.delayed(Duration.zero);
    expect(emitted, [const Unauthenticated(), const Authenticated()]);
    await sub.cancel();
  });

  test('wrong credentials → Failure, still signed out', () async {
    await auth.restoreSession();
    final r = await auth.login(
      const PasswordCredentials(username: 'u', password: 'no'),
    );
    expect(r.errorOrNull, isA<UnauthorizedException>());
    expect(auth.isAuthenticated, isFalse);
  });

  test('refresh is single-flight and keeps refresh token', () async {
    await auth.login(const PasswordCredentials(username: 'u', password: 'ok'));
    final results = await Future.wait([
      auth.refreshToken(),
      auth.refreshToken(),
      auth.refreshToken(),
    ]);
    expect(results, [true, true, true]);
    expect(api.refreshCalls, 1);
    expect((await storage.read())!.refreshToken, 'r1');
    expect(await auth.accessToken, 'a2');
  });

  test('expired token is refreshed proactively on read', () async {
    await storage.save(
      AuthTokens(
        accessToken: 'stale',
        refreshToken: 'r',
        expiresAt: DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
      ),
    );
    expect(await auth.restoreSession(), const Authenticated());
    expect(await auth.accessToken, 'a2');
  });

  test('rejected refresh returns false; network error rethrows', () async {
    await auth.login(const PasswordCredentials(username: 'u', password: 'ok'));
    api.refreshError = const UnauthorizedException();
    expect(await auth.refreshToken(), isFalse);

    api.refreshError = const NetworkException();
    await expectLater(auth.refreshToken(), throwsA(isA<NetworkException>()));
    expect(auth.isAuthenticated, isTrue); // not logged out by flaky network
  });

  test('onSessionExpired clears session', () async {
    await auth.login(const PasswordCredentials(username: 'u', password: 'ok'));
    await auth.onSessionExpired();
    expect(
      auth.currentStatus,
      const Unauthenticated(SignedOutReason.sessionExpired),
    );
    expect(await storage.read(), isNull);
  });

  test('logout calls server and clears', () async {
    await auth.login(const PasswordCredentials(username: 'u', password: 'ok'));
    await auth.logout();
    expect(api.logoutCalls, 1);
    expect(
      auth.currentStatus,
      const Unauthenticated(SignedOutReason.userInitiated),
    );
    expect(await auth.accessToken, isNull);
  });

  test('AuthTokens.fromJson supports snake_case + expires_in', () {
    final now = DateTime.utc(2026);
    final t = AuthTokens.fromJson({
      'access_token': 'a',
      'refresh_token': 'r',
      'expires_in': 60,
    }, now: now);
    expect(t.expiresAt, now.add(const Duration(seconds: 60)));
    expect(t.isExpired(now: now), isFalse);
    expect(t.isExpired(now: now.add(const Duration(seconds: 45))), isTrue);
    expect(t.toString(), isNot(contains('accessToken')));
  });
}
