import 'package:fpdart/fpdart.dart';

import 'error_codes.dart';
import 'error_messages.dart';

// ════════════════════════════════════════════════════════════════
// Typedefs — dùng xuyên suốt app thay vì viết Either<Failure, T>
// ════════════════════════════════════════════════════════════════

/// Kết quả đồng bộ: `Result<User>` thay vì `Either<Failure, User>`
typedef Result<T> = Either<Failure, T>;

/// Kết quả bất đồng bộ: `AsyncResult<User>` thay vì `Future<Either<Failure, User>>`
typedef AsyncResult<T> = Future<Either<Failure, T>>;

// ════════════════════════════════════════════════════════════════
// Failure
// ════════════════════════════════════════════════════════════════

/// Lỗi trả về từ Repository → BLoC → UI.
///
/// Repository KHÔNG throw exception, luôn trả [Either<Failure, T>].
/// BLoC dùng `result.match(onLeft, onRight)` để xử lý.
///
/// Thứ tự ưu tiên khi xử lý:
///   1. [errorCode] → xử lý logic cụ thể (switch/case trong BLoC)
///   2. Failure type → xử lý theo nhóm (unauthorized → logout)
///   3. [displayMessage] → hiển thị cho user
sealed class Failure {
  final String message;
  final String? errorCode;

  const Failure(this.message, {this.errorCode});

  /// Message hiển thị cho user — theo locale hiện tại.
  ///
  /// Ưu tiên: errorCode map → HTTP status message → backend message → fallback
  String get displayMessage {
    if (errorCode != null) {
      final mapped = ErrorMessages.fromCode(errorCode);
      if (mapped != ErrorMessages.fromCode(null)) return mapped;
    }
    return message;
  }

  /// Có nên tự động logout không.
  bool get shouldLogout => ErrorCodes.logoutCodes.contains(errorCode);

  /// Có nên hiện nút "Thử lại" không.
  bool get shouldRetry =>
      this is NetworkFailure ||
      this is TimeoutFailure ||
      ErrorCodes.retryCodes.contains(errorCode);

  @override
  String toString() => '[$runtimeType] ($errorCode) $message';
}

/// Lỗi từ server — có HTTP status code.
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.message, {super.errorCode, this.statusCode});

  @override
  String get displayMessage {
    // Ưu tiên 1: errorCode
    if (errorCode != null) {
      final mapped = ErrorMessages.fromCode(errorCode);
      if (mapped != ErrorMessages.fromCode(null)) return mapped;
    }

    // Ưu tiên 2: HTTP status message
    if (statusCode != null) {
      final statusMsg = _statusMessage;
      if (statusMsg != null) return statusMsg;
    }

    // Ưu tiên 3: backend message
    return message;
  }

  String? get _statusMessage => switch (statusCode!) {
    403 => ErrorMessages.fromCode(ErrorCodes.forbidden),
    404 => ErrorMessages.fromCode(ErrorCodes.notFound),
    429 => ErrorMessages.fromCode(ErrorCodes.rateLimited),
    >= 500 => ErrorMessages.fromCode(ErrorCodes.internalError),
    _ => null,
  };
}

/// Lỗi mạng — không có internet.
class NetworkFailure extends Failure {
  const NetworkFailure([String? message])
    : super(message ?? 'No internet connection');

  @override
  String get displayMessage => ErrorMessages.networkError;
}

/// Lỗi timeout — kết nối quá lâu.
class TimeoutFailure extends Failure {
  const TimeoutFailure([String? message])
    : super(message ?? 'Connection timed out');

  @override
  String get displayMessage => ErrorMessages.timeoutError;
}

/// Lỗi authentication — token hết hạn, chưa đăng nhập.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.errorCode}) : super('Unauthorized');

  @override
  bool get shouldLogout => true;

  @override
  String get displayMessage =>
      ErrorMessages.fromCode(errorCode ?? ErrorCodes.tokenExpired);
}

/// Lỗi validation — form fields không hợp lệ.
class ValidationFailure extends Failure {
  /// Map field name → list lỗi.
  /// Ví dụ: `{'email': ['Email đã tồn tại'], 'phone': ['Số không hợp lệ']}`
  final Map<String, List<String>> fieldErrors;

  const ValidationFailure(
    super.message, {
    super.errorCode,
    this.fieldErrors = const {},
  });

  /// Lấy lỗi đầu tiên của 1 field.
  String? getFieldError(String field) => fieldErrors[field]?.firstOrNull;

  /// Kiểm tra field có lỗi không.
  bool hasFieldError(String field) => fieldErrors.containsKey(field);

  /// Có field errors không (khác với message chung).
  bool get hasFieldErrors => fieldErrors.isNotEmpty;
}

/// Lỗi không xác định.
class UnknownFailure extends Failure {
  const UnknownFailure([String? message]) : super(message ?? 'Unknown error');

  @override
  String get displayMessage => ErrorMessages.fromCode(null, fallback: message);
}

class CacheFailure extends Failure {
  const CacheFailure([String? message]) : super(message ?? 'Cache error');

  @override
  String get displayMessage =>
      ErrorMessages.fromCode(errorCode, fallback: 'Lỗi dữ liệu local');
}

/// Ghi vào local DB vi phạm ràng buộc UNIQUE (trùng khoá).
class UniqueConstraintFailure extends CacheFailure {
  const UniqueConstraintFailure([super.message]);
}

/// Lỗi parse data — JSON format sai, type mismatch.
class ParseFailure extends Failure {
  const ParseFailure([String? message]) : super(message ?? 'Parse error');

  @override
  String get displayMessage =>
      ErrorMessages.fromCode(null, fallback: 'Dữ liệu không đúng định dạng');
}

/// Lỗi device/platform — printer, bluetooth, biometric, GPS.
class DeviceFailure extends Failure {
  const DeviceFailure(super.message, {super.errorCode});

  @override
  String get displayMessage =>
      ErrorMessages.fromCode(errorCode, fallback: message);
}

/// Lỗi business logic — không liên quan network hay device.
/// Ví dụ: cart rỗng khi checkout, coupon không áp dụng được.
class BusinessFailure extends Failure {
  const BusinessFailure(super.message, {super.errorCode});

  @override
  String get displayMessage =>
      ErrorMessages.fromCode(errorCode, fallback: message);
}
