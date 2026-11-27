import 'package:dio/dio.dart';

import '../api_options.dart';

/// Port implemented by the `auth` package. Keeps `api_client` unaware of
/// how tokens are stored or refreshed.
abstract interface class AuthTokenProvider {
  /// Current access token, or `null` when signed out.
  Future<String?> get accessToken;

  /// Obtains a new access token. Implementations must be single-flight:
  /// concurrent calls share the same in-progress refresh.
  ///
  /// Returns `true` on success.
  Future<bool> refreshToken();

  /// Called when refresh failed – the session is unrecoverable.
  Future<void> onSessionExpired();
}

/// Attaches `Authorization: Bearer <token>` and transparently refreshes the
/// token once on 401, then replays the original request.
///
/// Concurrency: a burst of parallel 401s triggers a single refresh because
/// [AuthTokenProvider.refreshToken] is single-flight; a 401 that arrives
/// after the token already changed is replayed directly without refreshing.
///
/// Deliberately *not* a `QueuedInterceptor`: replaying through the same
/// [Dio] from inside a queued `onError` deadlocks when the replay fails.
final class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenProvider,
    required this.dio,
    this.headerName = 'Authorization',
    this.scheme = 'Bearer',
  });

  final AuthTokenProvider tokenProvider;

  /// Client used to replay requests (the same [Dio] this interceptor is on).
  final Dio dio;
  final String headerName;
  final String scheme;

  String _format(String token) => '$scheme $token';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.requiresAuth) {
      final token = await tokenProvider.accessToken;
      if (token != null) options.headers[headerName] = _format(token);
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final shouldHandle =
        err.response?.statusCode == 401 &&
        request.requiresAuth &&
        !request.authRetried;
    if (!shouldHandle) return handler.next(err);

    try {
      // Another queued request may already have refreshed the token.
      final sentHeader = request.headers[headerName];
      var token = await tokenProvider.accessToken;
      final alreadyRefreshed = token != null && sentHeader != _format(token);

      if (!alreadyRefreshed) {
        final ok = await tokenProvider.refreshToken();
        token = ok ? await tokenProvider.accessToken : null;
      }

      if (token == null) {
        await tokenProvider.onSessionExpired();
        return handler.next(err);
      }

      final retry = request.copyWith(
        headers: {...request.headers, headerName: _format(token)},
        extra: {...request.extra, ApiExtra.authRetried: true},
      );
      handler.resolve(await dio.fetch<dynamic>(retry));
    } on DioException catch (e) {
      handler.next(e);
    } catch (e, st) {
      handler.next(
        DioException(requestOptions: request, error: e, stackTrace: st),
      );
    }
  }
}
