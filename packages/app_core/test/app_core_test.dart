import 'package:api_client/api_client.dart';
import 'package:app_core/app_core.dart';
import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:storage/storage.dart';

class _FakeAuthApi implements AuthApi {
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
  Future<AuthTokens> refresh(String refreshToken) async =>
      throw const UnauthorizedException();

  @override
  Future<void> logout({String? refreshToken}) async {}

  @override
  Future<OtpChallenge> requestOtp(String phone) async =>
      const OtpChallenge(requestId: 'req');
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('AuthBloc', () {
    late AuthManager auth;
    late AuthBloc bloc;

    setUp(() async {
      auth = AuthManager(
        api: _FakeAuthApi(),
        storage: SecureTokenStorage(SecureStorageService()),
      );
      await auth.restoreSession();
      bloc = AuthBloc(auth);
    });

    tearDown(() async {
      await bloc.close();
      await auth.dispose();
    });

    test('starts from the manager status', () {
      expect(bloc.state.status, const Unauthenticated());
      expect(bloc.state.isAuthenticated, isFalse);
    });

    test('successful login → Authenticated, no error', () async {
      bloc.add(
        const AuthEvent.loginRequested(
          PasswordCredentials(username: 'u', password: 'ok'),
        ),
      );
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<AuthState>()
              .having((s) => s.isAuthenticated, 'isAuthenticated', isTrue)
              .having((s) => s.isSubmitting, 'isSubmitting', isFalse)
              .having((s) => s.error, 'error', isNull),
        ),
      );
    });

    test('failed login exposes the error and stays signed out', () async {
      bloc.add(
        const AuthEvent.loginRequested(
          PasswordCredentials(username: 'u', password: 'bad'),
        ),
      );
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<AuthState>()
              .having((s) => s.isSubmitting, 'isSubmitting', isFalse)
              .having((s) => s.error, 'error', isA<UnauthorizedException>()),
        ),
      );
      expect(bloc.state.isAuthenticated, isFalse);
    });

    test('logout → Unauthenticated', () async {
      await auth.login(
        const PasswordCredentials(username: 'u', password: 'ok'),
      );
      await pumpEventQueue();
      expect(bloc.state.isAuthenticated, isTrue);

      bloc.add(const AuthEvent.logoutRequested());
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<AuthState>()
              .having((s) => s.isAuthenticated, 'isAuthenticated', isFalse)
              .having((s) => s.isSubmitting, 'isSubmitting', isFalse),
        ),
      );
    });

    test('session expiry outside the bloc is mirrored', () async {
      await auth.login(
        const PasswordCredentials(username: 'u', password: 'ok'),
      );
      await pumpEventQueue();
      await auth.onSessionExpired();
      await pumpEventQueue();
      expect(bloc.state.isAuthenticated, isFalse);
    });
  });

  group('ThemeModeCubit', () {
    test('defaults to system, persists and restores the choice', () async {
      final prefs = SharedPreferencesStorageService(namespace: 't');
      final cubit = ThemeModeCubit(prefs);
      await cubit.load();
      expect(cubit.state, ThemeMode.system);

      await cubit.setMode(ThemeMode.dark);
      expect(cubit.state, ThemeMode.dark);
      await cubit.close();

      final restored = ThemeModeCubit(prefs);
      await restored.load();
      expect(restored.state, ThemeMode.dark);
      await restored.close();
    });

    test('unknown saved value falls back to system', () async {
      final prefs = SharedPreferencesStorageService();
      await prefs.set('app.theme_mode', 'neon');
      final cubit = ThemeModeCubit(prefs);
      await cubit.load();
      expect(cubit.state, ThemeMode.system);
      await cubit.close();
    });
  });

  test('AppDependencies wires auth into the API client', () async {
    final deps = await AppDependencies.create(
      config: const AppConfig(flavor: Flavor.dev, apiBaseUrl: 'https://x'),
      namespace: 'test',
      logger: const NoopLogger(),
    );
    expect(deps.apiClient.config.baseUrl, 'https://x');
    expect(deps.auth.currentStatus, const AuthUnknown());
    expect(await deps.auth.restoreSession(), const Unauthenticated());
    // Fresh-install flag was written through the namespaced prefs.
    expect(await deps.prefs.get<bool>('storage.secure_initialized'), isTrue);
    expect(deps.apiClient, isA<ApiClient>());
    await deps.auth.dispose();
  });

  test('AppBlocObserver logs state types, not state contents', () async {
    final lines = <String>[];
    final previous = Bloc.observer;
    Bloc.observer = AppBlocObserver(ConsoleLogger(sink: lines.add));
    addTearDown(() => Bloc.observer = previous);

    final cubit = ThemeModeCubit(SharedPreferencesStorageService());
    await cubit.setMode(ThemeMode.dark);
    await cubit.close();
    expect(lines.single, 'D [bloc] ThemeModeCubit: ThemeMode → ThemeMode');
  });
}
