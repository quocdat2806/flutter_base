import 'package:core/core.dart';
import 'package:dio/dio.dart';

/// Extracts a human message, business code and field errors from an error
/// response body. Override to match your backend's contract.
typedef ErrorBodyParser = ParsedErrorBody Function(Object? body);

/// Normalised view of an error response body.
final class ParsedErrorBody {
  const ParsedErrorBody({this.message, this.code, this.fieldErrors = const {}});

  final String? message;
  final String? code;
  final Map<String, List<String>> fieldErrors;
}

/// Translates [DioException]s into the [AppException] hierarchy from `core`.
final class ApiErrorMapper {
  const ApiErrorMapper({this.parseBody = defaultErrorBodyParser});

  final ErrorBodyParser parseBody;

  AppException map(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) return error;
    if (error is! DioException) return UnknownException.from(error, stackTrace);
    // An interceptor may already have produced a domain error.
    if (error.error case final AppException inner) return inner;

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => const RequestTimeoutException(),
      DioExceptionType.cancel => const CancelledException(),
      DioExceptionType.connectionError => NetworkException.withCause(
        error.message ?? 'Connection error',
        cause: error,
        stackTrace: stackTrace,
      ),
      DioExceptionType.badCertificate => NetworkException.withCause(
        'Bad certificate',
        cause: error,
        stackTrace: stackTrace,
      ),
      DioExceptionType.badResponse => _fromResponse(error, stackTrace),
      DioExceptionType.unknown => UnknownException(
        error.message ?? error.error?.toString() ?? 'Unknown network error',
        cause: error,
        stackTrace: stackTrace,
      ),
    };
  }

  AppException _fromResponse(DioException error, StackTrace? stackTrace) {
    final response = error.response;
    final status = response?.statusCode ?? 0;
    final parsed = parseBody(response?.data);
    final message = parsed.message ?? response?.statusMessage ?? 'HTTP $status';

    return switch (status) {
      400 || 422 when parsed.fieldErrors.isNotEmpty => ValidationException(
        message,
        fieldErrors: parsed.fieldErrors,
        code: parsed.code,
      ),
      401 => UnauthorizedException(message),
      403 => ForbiddenException(message),
      404 => NotFoundException(message),
      _ => ServerException(
        message,
        statusCode: status,
        code: parsed.code,
        data: response?.data,
        cause: error,
        stackTrace: stackTrace,
      ),
    };
  }
}

/// Understands the common shapes:
/// `{ "message": "...", "code": "...", "errors": { "field": ["..."] } }`
/// and `{ "error": { "message": "...", "code": "..." } }`.
ParsedErrorBody defaultErrorBodyParser(Object? body) {
  if (body is! Map) {
    return ParsedErrorBody(
      message: body is String && body.isNotEmpty ? body : null,
    );
  }
  final root = body['error'] is Map ? body['error'] as Map : body;
  final rawErrors = root['errors'] ?? body['errors'];

  final fieldErrors = <String, List<String>>{};
  if (rawErrors is Map) {
    rawErrors.forEach((key, value) {
      fieldErrors['$key'] = switch (value) {
        final List<dynamic> list => list.map((e) => '$e').toList(),
        null => const [],
        _ => ['$value'],
      };
    });
  }

  return ParsedErrorBody(
    message: (root['message'] ?? root['detail'])?.toString(),
    code: root['code']?.toString(),
    fieldErrors: fieldErrors,
  );
}
