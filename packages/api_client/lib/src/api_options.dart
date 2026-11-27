import 'package:dio/dio.dart';

/// Keys stored in `RequestOptions.extra` to control interceptor behaviour
/// per request.
abstract final class ApiExtra {
  /// `false` → [AuthInterceptor] neither attaches a token nor tries to
  /// refresh on 401. Use for login / refresh / public endpoints.
  static const requiresAuth = 'api.requiresAuth';

  /// Set internally once a request has been replayed after a refresh.
  static const authRetried = 'api.authRetried';

  /// Attempt counter used by [RetryInterceptor].
  static const retryAttempt = 'api.retryAttempt';

  /// `true` → [RetryInterceptor] may retry even non-idempotent methods.
  static const forceRetry = 'api.forceRetry';
}

/// Readable accessors over [ApiExtra].
extension ApiRequestOptionsX on RequestOptions {
  bool get requiresAuth => extra[ApiExtra.requiresAuth] as bool? ?? true;
  bool get authRetried => extra[ApiExtra.authRetried] as bool? ?? false;
  int get retryAttempt => extra[ApiExtra.retryAttempt] as int? ?? 0;
  bool get forceRetry => extra[ApiExtra.forceRetry] as bool? ?? false;
}

/// Convenience to build per-request [Options].
Options apiOptions({
  bool requiresAuth = true,
  bool forceRetry = false,
  Map<String, Object?>? headers,
  Duration? receiveTimeout,
  ResponseType? responseType,
  String? contentType,
}) => Options(
  headers: headers,
  receiveTimeout: receiveTimeout,
  responseType: responseType,
  contentType: contentType,
  extra: {ApiExtra.requiresAuth: requiresAuth, ApiExtra.forceRetry: forceRetry},
);
