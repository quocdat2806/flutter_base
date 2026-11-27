import 'dart:convert';

import 'package:core/core.dart';
import 'package:dio/dio.dart';

/// Compact request/response logger that redacts credentials.
final class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({
    required this.logger,
    this.logBodies = true,
    this.maxBodyLength = 2000,
    Set<String> redactedHeaders = const {
      'authorization',
      'cookie',
      'x-api-key',
    },
    Set<String> redactedFields = const {
      'password',
      'accessToken',
      'access_token',
      'refreshToken',
      'refresh_token',
      'otp',
    },
  }) : _redactedHeaders = redactedHeaders.map((h) => h.toLowerCase()).toSet(),
       _redactedFields = redactedFields;

  final AppLogger logger;
  final bool logBodies;
  final int maxBodyLength;
  final Set<String> _redactedHeaders;
  final Set<String> _redactedFields;

  static const _tag = 'http';
  static const _startKey = 'api.startedAt';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = DateTime.now().millisecondsSinceEpoch;
    final headers = {
      for (final e in options.headers.entries)
        e.key: _redactedHeaders.contains(e.key.toLowerCase()) ? '***' : e.value,
    };
    logger.d(
      '→ ${options.method} ${options.uri}\n'
      '  headers: $headers'
      '${logBodies && options.data != null ? '\n  body: ${_body(options.data)}' : ''}',
      tag: _tag,
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final req = response.requestOptions;
    logger.d(
      '← ${response.statusCode} ${req.method} ${req.uri} (${_elapsed(req)}ms)'
      '${logBodies ? '\n  body: ${_body(response.data)}' : ''}',
      tag: _tag,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final req = err.requestOptions;
    logger.w(
      '✕ ${err.response?.statusCode ?? err.type.name} ${req.method} ${req.uri} '
      '(${_elapsed(req)}ms)'
      '${err.response?.data != null ? '\n  body: ${_body(err.response!.data)}' : ''}',
      tag: _tag,
      error: err.message,
    );
    handler.next(err);
  }

  int _elapsed(RequestOptions req) {
    final start = req.extra[_startKey] as int?;
    return start == null ? -1 : DateTime.now().millisecondsSinceEpoch - start;
  }

  String _body(Object? data) {
    final text = switch (data) {
      final Map<dynamic, dynamic> m => jsonEncode(_redact(m)),
      final List<dynamic> l => jsonEncode(l),
      FormData() => '<multipart>',
      null => 'null',
      _ => data.toString(),
    };
    return text.length > maxBodyLength
        ? '${text.substring(0, maxBodyLength)}…(${text.length} chars)'
        : text;
  }

  Object? _redact(Object? value) => switch (value) {
    final Map<dynamic, dynamic> m => {
      for (final e in m.entries)
        '${e.key}': _redactedFields.contains('${e.key}')
            ? '***'
            : _redact(e.value),
    },
    final List<dynamic> l => l.map(_redact).toList(),
    _ => value,
  };
}
