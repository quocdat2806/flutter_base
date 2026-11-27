import '../formatters/phone_formatter.dart';

/// Signature compatible with `TextFormField.validator`.
typedef Validator = String? Function(String? value);

/// Composable form validators.
///
/// Messages default to Vietnamese; pass `message:` to override (e.g. with a
/// localized string from `AppLocalizations`).
///
/// ```dart
/// validator: Validators.compose([
///   Validators.required(),
///   Validators.vnPhone(),
/// ]),
/// ```
abstract final class Validators {
  static final _email = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
  );
  static final _digits = RegExp(r'^\d+$');

  /// Runs [validators] in order and returns the first error.
  static Validator compose(List<Validator> validators) => (value) {
    for (final validate in validators) {
      final error = validate(value);
      if (error != null) return error;
    }
    return null;
  };

  /// Skips [validator] when the value is empty (for optional fields).
  static Validator optional(Validator validator) =>
      (value) =>
          (value == null || value.trim().isEmpty) ? null : validator(value);

  static Validator required({String message = 'Vui lòng nhập thông tin'}) =>
      (value) => (value == null || value.trim().isEmpty) ? message : null;

  static Validator email({String message = 'Email không hợp lệ'}) =>
      (value) => _email.hasMatch(value?.trim() ?? '') ? null : message;

  /// Vietnamese mobile number: `0912345678`, `+84912345678`, `84912345678`.
  static Validator vnPhone({String message = 'Số điện thoại không hợp lệ'}) =>
      (value) => PhoneFormatter.isValidVnMobile(value ?? '') ? null : message;

  static Validator minLength(int min, {String? message}) =>
      (value) => (value?.length ?? 0) >= min
      ? null
      : message ?? 'Tối thiểu $min ký tự';

  static Validator maxLength(int max, {String? message}) =>
      (value) =>
          (value?.length ?? 0) <= max ? null : message ?? 'Tối đa $max ký tự';

  static Validator digitsOnly({String message = 'Chỉ được nhập số'}) =>
      (value) => _digits.hasMatch(value ?? '') ? null : message;

  /// OTP of exactly [length] digits.
  static Validator otp({int length = 6, String? message}) =>
      (value) =>
          (value != null && value.length == length && _digits.hasMatch(value))
          ? null
          : message ?? 'Mã OTP gồm $length chữ số';

  /// At least [minLength] chars with upper, lower and digit.
  static Validator password({int minLength = 8, String? message}) => (value) {
    final v = value ?? '';
    final ok =
        v.length >= minLength &&
        v.contains(RegExp('[A-Z]')) &&
        v.contains(RegExp('[a-z]')) &&
        v.contains(RegExp(r'\d'));
    return ok
        ? null
        : message ??
              'Mật khẩu tối thiểu $minLength ký tự, gồm chữ hoa, chữ thường và số';
  };

  /// Matches another field, e.g. password confirmation.
  static Validator match(
    String Function() other, {
    String message = 'Giá trị không khớp',
  }) =>
      (value) => value == other() ? null : message;

  /// Vietnamese citizen ID (CCCD, 12 digits) or legacy CMND (9 digits).
  static Validator vnNationalId({
    String message = 'Số CCCD/CMND không hợp lệ',
  }) => (value) {
    final v = value?.trim() ?? '';
    return _digits.hasMatch(v) && (v.length == 12 || v.length == 9)
        ? null
        : message;
  };
}
