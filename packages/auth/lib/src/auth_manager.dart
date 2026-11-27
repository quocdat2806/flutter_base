import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:core/core.dart';

import 'data/auth_api.dart';
import 'data/token_storage.dart';
import 'models/auth_status.dart';
import 'models/auth_tokens.dart';
import 'models/credentials.dart';

/// Owns the user session: restores it at startup, signs in/out, keeps the
/// access token fresh and broadcasts [AuthStatus] changes.
///
/// Implements [AuthTokenProvider] so it plugs straight into [ApiClient]:
///
/// ```dart
/// final api = ApiClient(config: ...);
/// final auth = AuthManager(
///   api: RestAuthApi(api),
///   storage: SecureTokenStorage(SecureStorageService()),
/// );
/// api.setTokenProvider(auth);
/// await auth.restoreSession();
/// ```
///
/// Use [status] to drive `go_router`'s `refreshListenable` / redirect or an
/// `AuthBloc`.
final class AuthManager implements AuthTokenProvider {
  AuthManager({
    required AuthApi api,
    required TokenStorage storage,
    AppLogger logger = const NoopLogger(),
    this.refreshLeeway = const Duration(seconds: 30),
    this.logoutTimeout = const Duration(seconds: 5),
  }) : _api = api,
       _storage = storage,
       _logger = logger;

  final AuthApi _api;
  final TokenStorage _storage;
  final AppLogger _logger;

  /// Refresh proactively when the access token expires within this window.
  final Duration refreshLeeway;

  /// Upper bound for the best-effort server-side logout.
  final Duration logoutTimeout;

  static const _tag = 'auth';

  final _controller = StreamController<AuthStatus>.broadcast();
  AuthStatus _status = const AuthUnknown();
  AuthTokens? _tokens;
  Completer<bool>? _refreshing;
  bool _loggingOut = false;

  // ----------------------------------------------------------------- state --

  AuthStatus get currentStatus => _status;
  bool get isAuthenticated => _status is Authenticated;

  /// Emits the current status immediately, then every change.
  Stream<AuthStatus> get status async* {
    yield _status;
    yield* _controller.stream;
  }

  void _emit(AuthStatus next) {
    if (next == _status) return;
    _status = next;
    _logger.i('status → $next', tag: _tag);
    if (!_controller.isClosed) _controller.add(next);
  }

  // ------------------------------------------------------------- lifecycle --

  /// Loads persisted tokens. Call once during app startup (splash).
  Future<AuthStatus> restoreSession() async {
    try {
      _tokens = await _storage.read();
    } on AppException catch (e) {
      _logger.w('restore failed', tag: _tag, error: e);
      _tokens = null;
    }
    final tokens = _tokens;
    if (tokens == null) {
      _emit(const Unauthenticated());
    } else if (tokens.isExpired(leeway: Duration.zero) && !tokens.canRefresh) {
      await _clear(SignedOutReason.sessionExpired);
    } else {
      // Expired-but-refreshable tokens are refreshed lazily on first request
      // so startup never blocks on the network.
      _emit(const Authenticated());
    }
    return _status;
  }

  Future<Result<OtpChallenge>> requestOtp(String phone) =>
      Result.guard(() => _api.requestOtp(phone));

  Future<VoidResult> login(LoginCredentials credentials) =>
      Result.guard(() async {
        final tokens = await _api.login(credentials);
        await _setTokens(tokens);
      });

  /// For flows that obtain tokens elsewhere (social login, sign-up, deep
  /// link magic link…).
  Future<VoidResult> signInWithTokens(AuthTokens tokens) =>
      Result.guard(() => _setTokens(tokens));

  /// Revokes server-side (best effort, bounded by [logoutTimeout]) and
  /// always clears the local session.
  Future<void> logout() async {
    if (_loggingOut) return;
    _loggingOut = true;
    try {
      final refresh = _tokens?.refreshToken;
      if (_tokens != null) {
        await _api.logout(refreshToken: refresh).timeout(logoutTimeout);
      }
    } catch (e) {
      _logger.w('server logout failed (ignored)', tag: _tag, error: e);
    } finally {
      await _clear(SignedOutReason.userInitiated);
      _loggingOut = false;
    }
  }

  Future<void> dispose() => _controller.close();

  // --------------------------------------------------- AuthTokenProvider --

  @override
  Future<String?> get accessToken async {
    if (_refreshing case final inFlight?) await inFlight.future;
    final tokens = _tokens;
    if (tokens == null) return null;

    if (tokens.isExpired(leeway: refreshLeeway) && tokens.canRefresh) {
      try {
        await refreshToken();
      } on AppException catch (e) {
        // Transient failure: send the old token; the 401 path will retry.
        _logger.w('proactive refresh failed', tag: _tag, error: e);
      }
    }
    return _tokens?.accessToken;
  }

  /// Single-flight refresh.
  ///
  /// Returns `false` when the server rejected the refresh token (session is
  /// dead). Throws the [AppException] on transient errors (offline,
  /// timeout, 5xx) so the user is **not** logged out by a flaky network.
  @override
  Future<bool> refreshToken() {
    if (_refreshing case final inFlight?) return inFlight.future;

    final completer = _refreshing = Completer<bool>();
    // Avoid "unhandled error" when nobody awaits a failed refresh.
    completer.future.ignore();
    _doRefresh()
        .then(completer.complete, onError: completer.completeError)
        .whenComplete(() => _refreshing = null);
    return completer.future;
  }

  Future<bool> _doRefresh() async {
    final refresh = _tokens?.refreshToken;
    if (refresh == null || refresh.isEmpty) return false;
    try {
      final fresh = await _api.refresh(refresh);
      final current = _tokens;
      // User logged out while the refresh was in flight.
      if (current == null) return false;
      await _setTokens(current.mergeWith(fresh));
      _logger.d('token refreshed', tag: _tag);
      return true;
    } on UnauthorizedException {
      return false;
    } on ForbiddenException {
      return false;
    } on ValidationException {
      return false;
    } on ServerException catch (e) {
      if (e.statusCode == 400) return false;
      rethrow;
    }
  }

  @override
  Future<void> onSessionExpired() async {
    if (_loggingOut || _status is Unauthenticated) return;
    await _clear(SignedOutReason.sessionExpired);
  }

  // --------------------------------------------------------------- private --

  Future<void> _setTokens(AuthTokens tokens) async {
    _tokens = tokens;
    await _storage.save(tokens);
    _emit(const Authenticated());
  }

  Future<void> _clear(SignedOutReason reason) async {
    _tokens = null;
    try {
      await _storage.clear();
    } on AppException catch (e) {
      _logger.e('failed to clear tokens', tag: _tag, error: e);
    }
    _emit(Unauthenticated(reason));
  }
}
