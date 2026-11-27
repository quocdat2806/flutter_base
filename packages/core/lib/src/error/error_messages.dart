/// Map [ErrorCodes] → message hiển thị cho user theo locale.
///
/// Thứ tự ưu tiên khi hiển thị:
///   1. errorCode → map qua đây → message đúng ngôn ngữ
///   2. HTTP status code → message chung theo nhóm
///   3. message gốc từ backend → fallback cuối cùng
///
/// Cách dùng:
/// ```dart
/// ErrorMessages.setLocale('vi');
/// final msg = ErrorMessages.fromCode('WRONG_PASSWORD');
/// // → "Sai mật khẩu"
/// ```
class ErrorMessages {
  ErrorMessages._();

  static String _locale = 'vi';

  /// Gọi 1 lần khi app start hoặc khi user đổi ngôn ngữ.
  static void setLocale(String locale) => _locale = locale;

  /// Locale hiện tại.
  static String get currentLocale => _locale;

  /// Map errorCode → message theo locale hiện tại.
  ///
  /// Trả [fallback] nếu errorCode không có trong map.
  /// Trả message mặc định nếu cả errorCode lẫn fallback đều null.
  static String fromCode(String? errorCode, {String? fallback}) {
    if (errorCode == null) return fallback ?? _defaultMessage;

    final messages = _all[_locale] ?? _all['en']!;
    return messages[errorCode] ?? fallback ?? _defaultMessage;
  }

  /// Message mặc định khi không map được.
  static String get _defaultMessage =>
      _locale == 'vi' ? 'Đã có lỗi xảy ra' : 'Something went wrong';

  /// Message cho lỗi mạng.
  static String get networkError =>
      _locale == 'vi' ? 'Không có kết nối mạng' : 'No internet connection';

  /// Message cho timeout.
  static String get timeoutError => _locale == 'vi'
      ? 'Kết nối quá thời gian, vui lòng thử lại'
      : 'Connection timed out, please try again';

  /// Message cho unauthorized.
  static String get unauthorizedError =>
      _locale == 'vi' ? 'Phiên đăng nhập hết hạn' : 'Session expired';

  // ════════════════════════════════════════════════════════════════
  // Message maps — thêm locale mới: thêm 1 map + register vào _all
  // ════════════════════════════════════════════════════════════════

  static const _all = {'vi': _vi, 'en': _en};

  static const _vi = {
    // Auth
    'INVALID_CREDENTIALS': 'Email hoặc mật khẩu không đúng',
    'WRONG_PASSWORD': 'Sai mật khẩu',
    'ACCOUNT_LOCKED': 'Tài khoản đã bị khoá, vui lòng liên hệ hỗ trợ',
    'ACCOUNT_DISABLED': 'Tài khoản đã bị vô hiệu hoá',
    'ACCOUNT_NOT_VERIFIED': 'Tài khoản chưa được xác minh, kiểm tra email',
    'LOGIN_TOO_MANY_ATTEMPTS':
        'Đăng nhập sai quá nhiều lần, vui lòng thử lại sau 15 phút',
    'TOKEN_EXPIRED': 'Phiên đăng nhập hết hạn, vui lòng đăng nhập lại',
    'TOKEN_INVALID': 'Phiên đăng nhập không hợp lệ',
    'REFRESH_TOKEN_EXPIRED': 'Phiên đăng nhập hết hạn, vui lòng đăng nhập lại',
    'OTP_EXPIRED': 'Mã OTP đã hết hạn, vui lòng gửi lại',
    'OTP_INVALID': 'Mã OTP không đúng',
    'OTP_MAX_ATTEMPTS': 'Nhập sai OTP quá nhiều lần, vui lòng gửi mã mới',
    'EMAIL_ALREADY_EXISTS': 'Email đã được sử dụng',
    'PHONE_ALREADY_EXISTS': 'Số điện thoại đã được sử dụng',
    'PASSWORD_TOO_WEAK': 'Mật khẩu quá yếu, cần ít nhất 8 ký tự gồm chữ và số',
    'SAME_PASSWORD': 'Mật khẩu mới phải khác mật khẩu cũ',
    'SOCIAL_LOGIN_FAILED': 'Đăng nhập bằng mạng xã hội thất bại',

    // User
    'USER_NOT_FOUND': 'Không tìm thấy người dùng',
    'PROFILE_INCOMPLETE': 'Vui lòng hoàn thiện thông tin cá nhân',
    'AVATAR_TOO_LARGE': 'Ảnh đại diện quá lớn, tối đa 5MB',

    // Order
    'ORDER_NOT_FOUND': 'Không tìm thấy đơn hàng',
    'ORDER_ALREADY_CANCELLED': 'Đơn hàng đã được huỷ trước đó',
    'ORDER_ALREADY_SHIPPED':
        'Không thể huỷ, đơn hàng đã giao cho đơn vị vận chuyển',
    'ORDER_CANCEL_TIMEOUT': 'Đã quá thời gian cho phép huỷ đơn hàng',
    'ORDER_LIMIT_EXCEEDED': 'Vượt quá giới hạn số đơn hàng',
    'MINIMUM_ORDER_AMOUNT': 'Đơn hàng chưa đạt giá trị tối thiểu',

    // Product
    'PRODUCT_NOT_FOUND': 'Không tìm thấy sản phẩm',
    'PRODUCT_OUT_OF_STOCK': 'Sản phẩm đã hết hàng',
    'PRODUCT_DISCONTINUED': 'Sản phẩm đã ngừng kinh doanh',
    'PRODUCT_QUANTITY_EXCEEDED': 'Số lượng đặt vượt quá tồn kho',

    // Payment
    'PAYMENT_FAILED': 'Thanh toán thất bại, vui lòng thử lại',
    'PAYMENT_TIMEOUT': 'Thanh toán quá thời gian, vui lòng thử lại',
    'PAYMENT_DECLINED': 'Giao dịch bị từ chối bởi ngân hàng',
    'INSUFFICIENT_BALANCE': 'Số dư tài khoản không đủ',
    'INVALID_PAYMENT_METHOD': 'Phương thức thanh toán không hợp lệ',
    'REFUND_FAILED': 'Hoàn tiền thất bại, vui lòng liên hệ hỗ trợ',

    // Cart
    'CART_EMPTY': 'Giỏ hàng trống',
    'CART_ITEM_NOT_FOUND': 'Sản phẩm không có trong giỏ hàng',
    'CART_ITEM_LIMIT_EXCEEDED': 'Giỏ hàng đã đạt số lượng tối đa',

    // Voucher
    'VOUCHER_NOT_FOUND': 'Mã giảm giá không tồn tại',
    'VOUCHER_EXPIRED': 'Mã giảm giá đã hết hạn',
    'VOUCHER_ALREADY_USED': 'Mã giảm giá đã được sử dụng',
    'VOUCHER_MINIMUM_NOT_MET':
        'Đơn hàng chưa đạt giá trị tối thiểu để áp dụng mã giảm giá',
    'VOUCHER_NOT_APPLICABLE': 'Mã giảm giá không áp dụng cho đơn hàng này',

    // Address
    'ADDRESS_NOT_FOUND': 'Không tìm thấy địa chỉ',
    'ADDRESS_LIMIT_EXCEEDED': 'Đã đạt giới hạn số địa chỉ lưu trữ',
    'ADDRESS_OUT_OF_SERVICE_AREA': 'Địa chỉ ngoài khu vực phục vụ',

    // Upload
    'FILE_TOO_LARGE': 'File quá lớn, vui lòng chọn file nhỏ hơn',
    'FILE_TYPE_NOT_ALLOWED': 'Định dạng file không được hỗ trợ',
    'UPLOAD_FAILED': 'Tải file lên thất bại, vui lòng thử lại',

    // Validation
    'VALIDATION_ERROR': 'Dữ liệu không hợp lệ',

    // General
    'NOT_FOUND': 'Không tìm thấy',
    'FORBIDDEN': 'Bạn không có quyền thực hiện thao tác này',
    'UNAUTHORIZED': 'Phiên đăng nhập hết hạn',
    'RATE_LIMITED': 'Quá nhiều yêu cầu, vui lòng thử lại sau',
    'INTERNAL_ERROR': 'Lỗi hệ thống, vui lòng thử lại sau',
    'SERVICE_UNAVAILABLE': 'Hệ thống đang quá tải, vui lòng thử lại sau',
    'MAINTENANCE_MODE': 'Hệ thống đang bảo trì, vui lòng quay lại sau',
  };

  static const _en = {
    // Auth
    'INVALID_CREDENTIALS': 'Incorrect email or password',
    'WRONG_PASSWORD': 'Incorrect password',
    'ACCOUNT_LOCKED': 'Account is locked, please contact support',
    'ACCOUNT_DISABLED': 'Account has been disabled',
    'ACCOUNT_NOT_VERIFIED': 'Account is not verified, please check your email',
    'LOGIN_TOO_MANY_ATTEMPTS':
        'Too many login attempts, please try again in 15 minutes',
    'TOKEN_EXPIRED': 'Session expired, please sign in again',
    'TOKEN_INVALID': 'Invalid session',
    'REFRESH_TOKEN_EXPIRED': 'Session expired, please sign in again',
    'OTP_EXPIRED': 'OTP has expired, please request a new one',
    'OTP_INVALID': 'Invalid OTP code',
    'OTP_MAX_ATTEMPTS': 'Too many OTP attempts, please request a new code',
    'EMAIL_ALREADY_EXISTS': 'This email is already registered',
    'PHONE_ALREADY_EXISTS': 'This phone number is already registered',
    'PASSWORD_TOO_WEAK':
        'Password is too weak, must be at least 8 characters with letters and numbers',
    'SAME_PASSWORD': 'New password must be different from current password',
    'SOCIAL_LOGIN_FAILED': 'Social login failed',

    // User
    'USER_NOT_FOUND': 'User not found',
    'PROFILE_INCOMPLETE': 'Please complete your profile',
    'AVATAR_TOO_LARGE': 'Avatar is too large, maximum 5MB',

    // Order
    'ORDER_NOT_FOUND': 'Order not found',
    'ORDER_ALREADY_CANCELLED': 'This order has already been cancelled',
    'ORDER_ALREADY_SHIPPED': 'Cannot cancel, order has been shipped',
    'ORDER_CANCEL_TIMEOUT': 'Cancellation period has expired',
    'ORDER_LIMIT_EXCEEDED': 'Order limit exceeded',
    'MINIMUM_ORDER_AMOUNT': 'Order does not meet the minimum amount',

    // Product
    'PRODUCT_NOT_FOUND': 'Product not found',
    'PRODUCT_OUT_OF_STOCK': 'Product is out of stock',
    'PRODUCT_DISCONTINUED': 'Product is no longer available',
    'PRODUCT_QUANTITY_EXCEEDED': 'Quantity exceeds available stock',

    // Payment
    'PAYMENT_FAILED': 'Payment failed, please try again',
    'PAYMENT_TIMEOUT': 'Payment timed out, please try again',
    'PAYMENT_DECLINED': 'Transaction declined by bank',
    'INSUFFICIENT_BALANCE': 'Insufficient balance',
    'INVALID_PAYMENT_METHOD': 'Invalid payment method',
    'REFUND_FAILED': 'Refund failed, please contact support',

    // Cart
    'CART_EMPTY': 'Your cart is empty',
    'CART_ITEM_NOT_FOUND': 'Item not found in cart',
    'CART_ITEM_LIMIT_EXCEEDED': 'Cart has reached maximum items',

    // Voucher
    'VOUCHER_NOT_FOUND': 'Voucher not found',
    'VOUCHER_EXPIRED': 'Voucher has expired',
    'VOUCHER_ALREADY_USED': 'Voucher has already been used',
    'VOUCHER_MINIMUM_NOT_MET':
        'Order does not meet the minimum amount for this voucher',
    'VOUCHER_NOT_APPLICABLE': 'Voucher is not applicable for this order',

    // Address
    'ADDRESS_NOT_FOUND': 'Address not found',
    'ADDRESS_LIMIT_EXCEEDED': 'Maximum number of saved addresses reached',
    'ADDRESS_OUT_OF_SERVICE_AREA': 'Address is outside the service area',

    // Upload
    'FILE_TOO_LARGE': 'File is too large',
    'FILE_TYPE_NOT_ALLOWED': 'File type is not supported',
    'UPLOAD_FAILED': 'Upload failed, please try again',

    // Validation
    'VALIDATION_ERROR': 'Invalid data',

    // General
    'NOT_FOUND': 'Not found',
    'FORBIDDEN': 'You do not have permission to perform this action',
    'UNAUTHORIZED': 'Session expired',
    'RATE_LIMITED': 'Too many requests, please try again later',
    'INTERNAL_ERROR': 'System error, please try again later',
    'SERVICE_UNAVAILABLE': 'System is overloaded, please try again later',
    'MAINTENANCE_MODE': 'System is under maintenance, please try again later',
  };
}
