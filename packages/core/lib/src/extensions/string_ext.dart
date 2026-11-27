extension StringExt on String {
  // ══════════════════════════════
  // Validation
  // ══════════════════════════════
  bool get isValidEmail => RegexPatterns.email.hasMatch(this);
  bool get isValidPhone => RegexPatterns.phone.hasMatch(this);
  bool get isValidPassword => RegexPatterns.password.hasMatch(this);
  bool get isValidOtp => RegexPatterns.otp.hasMatch(this);
  bool get isValidUrl => RegexPatterns.url.hasMatch(this);
  bool get isNumeric => RegexPatterns.numeric.hasMatch(this);
  bool get isNullOrEmpty => isEmpty;
  bool get isNotNullOrEmpty => isNotEmpty;
  bool get isBlank => trim().isEmpty;
  bool get isNotBlank => trim().isNotEmpty;

  // ══════════════════════════════
  // Transform
  // ══════════════════════════════
  String get capitalize =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';

  String get capitalizeEachWord =>
      split(' ').map((w) => w.capitalize).join(' ');

  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  String get toSlug => toLowerCase()
      .replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
      .replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e')
      .replaceAll(RegExp(r'[ìíịỉĩ]'), 'i')
      .replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
      .replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u')
      .replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y')
      .replaceAll(RegExp(r'[đ]'), 'd')
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .replaceAll(RegExp(r'[\s-]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  // ══════════════════════════════
  // Mask — ẩn thông tin nhạy cảm
  // ══════════════════════════════
  String get maskPhone =>
      length > 4 ? '${'*' * (length - 4)}${substring(length - 4)}' : this;
  // 0901234567 → ******4567

  String get maskEmail {
    final parts = split('@');
    if (parts.length != 2) return this;
    final name = parts[0];
    final masked = name.length > 2
        ? '${name.substring(0, 2)}${'*' * (name.length - 2)}'
        : name;
    return '$masked@${parts[1]}';
  }
  // minh@gmail.com → mi**@gmail.com

  String get maskCardNumber {
    final clean = removeWhitespace;
    if (clean.length < 8) return this;
    return '${'*' * (clean.length - 4)} ${clean.substring(clean.length - 4)}';
  }
  // 4111111111111111 → **** 1111

  // ══════════════════════════════
  // Truncate
  // ══════════════════════════════
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }
  // "Sản phẩm rất dài tên".truncate(10) → "Sản phẩ..."

  // ══════════════════════════════
  // Parse
  // ══════════════════════════════
  int? get toIntOrNull => int.tryParse(this);
  double? get toDoubleOrNull => double.tryParse(this);
  DateTime? get toDateTimeOrNull => DateTime.tryParse(this);

  /// "1,500,000" → 1500000
  int? get currencyToInt => int.tryParse(replaceAll(RegExp(r'[^0-9]'), ''));
}
