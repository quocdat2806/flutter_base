class RegexPatterns {
  RegexPatterns._();

  static final email = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final phone = RegExp(r'^(0|\+84)[0-9]{9}$');
  static final password = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');
  static final otp = RegExp(r'^\d{6}$');
  static final url = RegExp(r'^https?://[\w\-]+(\.[\w\-]+)+[/#?]?.*$');
  static final numeric = RegExp(r'^\d+$');
  static final alphabetic = RegExp(r'^[a-zA-Z]+$');
  static final alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
  static final vietnameseName = RegExp(r'^[a-zA-ZÀ-ỹ\s]+$');
  static final noSpecialChars = RegExp(r'^[a-zA-Z0-9\s]+$');
}
