/// Mã lỗi chuẩn — match 1:1 với backend API docs.
///
/// Quy ước đặt tên: NHÓM_HÀNH_ĐỘNG hoặc NHÓM_TRẠNG_THÁI
/// Backend trả `errorCode` dạng String, app dùng constants này để so sánh.
///
/// Thêm mới: khi backend define error code mới, thêm vào đây + thêm message
/// trong [ErrorMessages].
class ErrorCodes {
  ErrorCodes._();

  // ══════════════════════════════════════════
  // AUTH
  // ══════════════════════════════════════════
  static const invalidCredentials = 'INVALID_CREDENTIALS';
  static const wrongPassword = 'WRONG_PASSWORD';
  static const accountLocked = 'ACCOUNT_LOCKED';
  static const accountDisabled = 'ACCOUNT_DISABLED';
  static const accountNotVerified = 'ACCOUNT_NOT_VERIFIED';
  static const loginTooManyAttempts = 'LOGIN_TOO_MANY_ATTEMPTS';
  static const tokenExpired = 'TOKEN_EXPIRED';
  static const tokenInvalid = 'TOKEN_INVALID';
  static const refreshTokenExpired = 'REFRESH_TOKEN_EXPIRED';
  static const otpExpired = 'OTP_EXPIRED';
  static const otpInvalid = 'OTP_INVALID';
  static const otpMaxAttempts = 'OTP_MAX_ATTEMPTS';
  static const emailAlreadyExists = 'EMAIL_ALREADY_EXISTS';
  static const phoneAlreadyExists = 'PHONE_ALREADY_EXISTS';
  static const passwordTooWeak = 'PASSWORD_TOO_WEAK';
  static const samePassword = 'SAME_PASSWORD';
  static const socialLoginFailed = 'SOCIAL_LOGIN_FAILED';

  // ══════════════════════════════════════════
  // USER
  // ══════════════════════════════════════════
  static const userNotFound = 'USER_NOT_FOUND';
  static const profileIncomplete = 'PROFILE_INCOMPLETE';
  static const avatarTooLarge = 'AVATAR_TOO_LARGE';

  // ══════════════════════════════════════════
  // ORDER
  // ══════════════════════════════════════════
  static const orderNotFound = 'ORDER_NOT_FOUND';
  static const orderAlreadyCancelled = 'ORDER_ALREADY_CANCELLED';
  static const orderAlreadyShipped = 'ORDER_ALREADY_SHIPPED';
  static const orderCancelTimeout = 'ORDER_CANCEL_TIMEOUT';
  static const orderLimitExceeded = 'ORDER_LIMIT_EXCEEDED';
  static const minimumOrderAmount = 'MINIMUM_ORDER_AMOUNT';

  // ══════════════════════════════════════════
  // PRODUCT
  // ══════════════════════════════════════════
  static const productNotFound = 'PRODUCT_NOT_FOUND';
  static const productOutOfStock = 'PRODUCT_OUT_OF_STOCK';
  static const productDiscontinued = 'PRODUCT_DISCONTINUED';
  static const productQuantityExceeded = 'PRODUCT_QUANTITY_EXCEEDED';

  // ══════════════════════════════════════════
  // PAYMENT
  // ══════════════════════════════════════════
  static const paymentFailed = 'PAYMENT_FAILED';
  static const paymentTimeout = 'PAYMENT_TIMEOUT';
  static const paymentDeclined = 'PAYMENT_DECLINED';
  static const insufficientBalance = 'INSUFFICIENT_BALANCE';
  static const invalidPaymentMethod = 'INVALID_PAYMENT_METHOD';
  static const refundFailed = 'REFUND_FAILED';

  // ══════════════════════════════════════════
  // CART
  // ══════════════════════════════════════════
  static const cartEmpty = 'CART_EMPTY';
  static const cartItemNotFound = 'CART_ITEM_NOT_FOUND';
  static const cartItemLimitExceeded = 'CART_ITEM_LIMIT_EXCEEDED';

  // ══════════════════════════════════════════
  // VOUCHER
  // ══════════════════════════════════════════
  static const voucherNotFound = 'VOUCHER_NOT_FOUND';
  static const voucherExpired = 'VOUCHER_EXPIRED';
  static const voucherAlreadyUsed = 'VOUCHER_ALREADY_USED';
  static const voucherMinimumNotMet = 'VOUCHER_MINIMUM_NOT_MET';
  static const voucherNotApplicable = 'VOUCHER_NOT_APPLICABLE';

  // ══════════════════════════════════════════
  // ADDRESS
  // ══════════════════════════════════════════
  static const addressNotFound = 'ADDRESS_NOT_FOUND';
  static const addressLimitExceeded = 'ADDRESS_LIMIT_EXCEEDED';
  static const addressOutOfServiceArea = 'ADDRESS_OUT_OF_SERVICE_AREA';

  // ══════════════════════════════════════════
  // UPLOAD
  // ══════════════════════════════════════════
  static const fileTooLarge = 'FILE_TOO_LARGE';
  static const fileTypeNotAllowed = 'FILE_TYPE_NOT_ALLOWED';
  static const uploadFailed = 'UPLOAD_FAILED';

  // ══════════════════════════════════════════
  // VALIDATION
  // ══════════════════════════════════════════
  static const validationError = 'VALIDATION_ERROR';

  // ══════════════════════════════════════════
  // GENERAL
  // ══════════════════════════════════════════
  static const notFound = 'NOT_FOUND';
  static const forbidden = 'FORBIDDEN';
  static const unauthorized = 'UNAUTHORIZED';
  static const rateLimited = 'RATE_LIMITED';
  static const internalError = 'INTERNAL_ERROR';
  static const serviceUnavailable = 'SERVICE_UNAVAILABLE';
  static const maintenanceMode = 'MAINTENANCE_MODE';

  /// Các errorCode mà app cần tự động logout.
  static const logoutCodes = {
    tokenExpired,
    tokenInvalid,
    refreshTokenExpired,
    unauthorized,
  };

  /// Các errorCode mà app nên hiện nút "Thử lại".
  static const retryCodes = {paymentTimeout, internalError, serviceUnavailable};
}
