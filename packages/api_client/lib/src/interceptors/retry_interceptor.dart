import 'dart:math';

import 'package:dio/dio.dart';

import '../api_options.dart';

/// Retries transient failures (connection errors, timeouts, 502/503/504)
/// with exponential backoff + jitter.
///
/// Only idempotent methods are retried unless the request sets
/// [ApiExtra.forceRetry], so a POST that reached the server is never sent
/// twice by accident.
final class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
    this.baseDelay = const Duration(milliseconds: 400),
    this.retryableStatuses = const {502, 503, 504},
    Random? random,
  }) : _random = random ?? Random();

  final Dio dio;
  final int maxRetries;
  final Duration baseDelay;
  final Set<int> retryableStatuses;
  final Random _random;

  static const _idempotent = {'GET', 'HEAD', 'OPTIONS', 'PUT', 'DELETE'};

  bool _isTransient(DioException err) => switch (err.type) {
    DioExceptionType.connectionError ||
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout => true,
    DioExceptionType.badResponse => retryableStatuses.contains(
      err.response?.statusCode,
    ),
    _ => false,
  };

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final req = err.requestOptions;
    final attempt = req.retryAttempt;
    final methodOk =
        _idempotent.contains(req.method.toUpperCase()) || req.forceRetry;

    if (attempt >= maxRetries || !methodOk || !_isTransient(err)) {
      return handler.next(err);
    }

    final backoff = baseDelay * pow(2, attempt).toInt();
    final jitter = Duration(milliseconds: _random.nextInt(250));
    await Future<void>.delayed(backoff + jitter);

    try {
      final response = await dio.fetch<dynamic>(
        req.copyWith(extra: {...req.extra, ApiExtra.retryAttempt: attempt + 1}),
      );
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
