import 'dart:io';

import 'package:dio/dio.dart';

import 'error_codes.dart';
import 'failure.dart';

/// Chuyển đổi Exception/Error → [Failure].
///
/// Dùng 1 chỗ duy nhất trong [RepositoryMixin.safeCall].
/// Không gọi trực tiếp trong BLoC hay UI.
class ErrorMapper {
  ErrorMapper._();

  /// Entry point chính — nhận bất kỳ error nào, trả Failure.
  static Failure toFailure(Object error, [StackTrace? stackTrace]) {
    if (error is Failure) return error;
    if (error is DioException) return _fromDio(error);
    if (error is SocketException) return const NetworkFailure();
    if (error is FormatException) {
      return const UnknownFailure('Dữ liệu không đúng định dạng');
    }
    if (error is TypeError) {
      return const UnknownFailure('Lỗi xử lý dữ liệu');
    }

    return UnknownFailure(error.toString());
  }

  /// Parse từ API response map (khi có body nhưng success = false).
  static Failure fromResponseData(
    Map<String, dynamic> data, {
    int? statusCode,
  }) {
    final message = _extractMessage(data);
    final errorCode = data['errorCode'] as String?;
    final errors = _extractFieldErrors(data);

    // Ưu tiên 1: errorCode cụ thể
    if (errorCode != null) {
      // Validation error với field errors
      if (errors.isNotEmpty || errorCode == ErrorCodes.validationError) {
        return ValidationFailure(
          message,
          errorCode: errorCode,
          fieldErrors: errors,
        );
      }

      // Unauthorized
      if (ErrorCodes.logoutCodes.contains(errorCode)) {
        return UnauthorizedFailure(errorCode: errorCode);
      }

      // Server/Business error với errorCode
      return ServerFailure(
        message,
        errorCode: errorCode,
        statusCode: statusCode,
      );
    }

    // Ưu tiên 2: HTTP status code
    return _fromStatusCode(statusCode, message, errors);
  }

  // ════════════════════════════════════════════════════════════════
  // Private helpers
  // ════════════════════════════════════════════════════════════════

  static Failure _fromDio(DioException e) {
    // Có response body → parse data
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return fromResponseData(data, statusCode: e.response?.statusCode);
    }

    // Không có body → dựa vào DioException type
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const TimeoutFailure(),
      DioExceptionType.connectionError => const NetworkFailure(),
      DioExceptionType.badResponse => _fromStatusCode(
        e.response?.statusCode,
        e.message ?? 'Server error',
        {},
      ),
      _ => NetworkFailure(e.message),
    };
  }

  static Failure _fromStatusCode(
    int? statusCode,
    String message,
    Map<String, List<String>> fieldErrors,
  ) {
    return switch (statusCode) {
      401 => const UnauthorizedFailure(),
      403 => ServerFailure(message, statusCode: 403),
      404 => ServerFailure(
        message,
        errorCode: ErrorCodes.notFound,
        statusCode: 404,
      ),
      422 => ValidationFailure(message, fieldErrors: fieldErrors),
      429 => ServerFailure(
        message,
        errorCode: ErrorCodes.rateLimited,
        statusCode: 429,
      ),
      >= 500 => ServerFailure(
        message,
        errorCode: ErrorCodes.internalError,
        statusCode: statusCode,
      ),
      _ => ServerFailure(message, statusCode: statusCode),
    };
  }

  static String _extractMessage(Map<String, dynamic> data) {
    return data['message'] as String? ??
        data['error'] as String? ??
        data['msg'] as String? ??
        'Unknown error';
  }

  static Map<String, List<String>> _extractFieldErrors(
    Map<String, dynamic> data,
  ) {
    final errors = data['errors'];
    if (errors is! Map) return {};

    return errors.map((key, value) {
      if (value is List) {
        return MapEntry(key as String, value.cast<String>());
      }
      return MapEntry(key as String, [value.toString()]);
    });
  }
}
