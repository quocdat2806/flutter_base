// packages/core/lib/src/validators/validators.dart

import '../constants/regex_patterns.dart';

class Validators {
  Validators._();

  // ══════════════════════════════
  // Auth
  // ══════════════════════════════
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập email';
    if (!RegexPatterns.email.hasMatch(value.trim()))
      return 'Email không hợp lệ';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 8) return 'Mật khẩu tối thiểu 8 ký tự';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Cần ít nhất 1 chữ hoa';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Cần ít nhất 1 số';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập lại mật khẩu';
    if (value != password) return 'Mật khẩu không khớp';
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mã OTP';
    if (value.length != 6) return 'Mã OTP phải có 6 số';
    if (!RegexPatterns.otp.hasMatch(value)) return 'Mã OTP chỉ chứa số';
    return null;
  }

  // ══════════════════════════════
  // User info
  // ══════════════════════════════
  static String? required(String? value, [String field = 'Trường này']) {
    if (value == null || value.trim().isEmpty)
      return '$field không được để trống';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập họ tên';
    if (value.trim().length < 2) return 'Họ tên tối thiểu 2 ký tự';
    if (value.trim().length > 50) return 'Họ tên tối đa 50 ký tự';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Vui lòng nhập số điện thoại';
    if (!RegexPatterns.phone.hasMatch(value.trim()))
      return 'Số điện thoại không hợp lệ';
    return null;
  }

  // ══════════════════════════════
  // Number
  // ══════════════════════════════
  static String? number(String? value, [String field = 'Giá trị']) {
    if (value == null || value.trim().isEmpty)
      return '$field không được để trống';
    if (double.tryParse(value) == null) return '$field phải là số';
    return null;
  }

  static String? positiveNumber(String? value, [String field = 'Giá trị']) {
    final error = number(value, field);
    if (error != null) return error;
    if (double.parse(value!) <= 0) return '$field phải lớn hơn 0';
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập giá';
    final parsed = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (parsed == null) return 'Giá không hợp lệ';
    if (parsed <= 0) return 'Giá phải lớn hơn 0';
    return null;
  }

  static String? quantity(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập số lượng';
    final parsed = int.tryParse(value);
    if (parsed == null) return 'Số lượng phải là số nguyên';
    if (parsed <= 0) return 'Số lượng phải lớn hơn 0';
    if (parsed > 999) return 'Số lượng tối đa 999';
    return null;
  }

  // ══════════════════════════════
  // Address
  // ══════════════════════════════
  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập địa chỉ';
    if (value.trim().length < 10) return 'Địa chỉ quá ngắn';
    if (value.trim().length > 200) return 'Địa chỉ tối đa 200 ký tự';
    return null;
  }

  // ══════════════════════════════
  // Text length
  // ══════════════════════════════
  static String? minLength(
    String? value,
    int min, [
    String field = 'Nội dung',
  ]) {
    if (value == null || value.trim().isEmpty)
      return '$field không được để trống';
    if (value.trim().length < min) return '$field tối thiểu $min ký tự';
    return null;
  }

  static String? maxLength(
    String? value,
    int max, [
    String field = 'Nội dung',
  ]) {
    if (value != null && value.length > max) return '$field tối đa $max ký tự';
    return null;
  }

  // ══════════════════════════════
  // URL
  // ══════════════════════════════
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    if (!RegexPatterns.url.hasMatch(value.trim())) return 'URL không hợp lệ';
    return null;
  }
}
