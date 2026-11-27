extension NumExt on num {
  // ══════════════════════════════
  // Format tiền VND
  // ══════════════════════════════
  String get currencyVND {
    final value = toInt().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      if (i > 0 && (value.length - i) % 3 == 0) buffer.write('.');
      buffer.write(value[i]);
    }
    return '${buffer}đ';
  }
  // 1500000.currencyVND → "1.500.000đ"

  /// Format với currency symbol tuỳ chọn.
  String currency({String symbol = 'đ', int decimals = 0}) {
    final value = toStringAsFixed(decimals);
    final parts = value.split('.');
    final intPart = parts[0];

    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write('.');
      buffer.write(intPart[i]);
    }

    if (parts.length > 1 && decimals > 0) {
      buffer.write(',${parts[1]}');
    }

    return '$buffer$symbol';
  }
  // 1500000.currency() → "1.500.000đ"
  // 29.99.currency(symbol: '\$', decimals: 2) → "29,99$"

  // ══════════════════════════════
  // Format rút gọn
  // ══════════════════════════════
  String get compact {
    if (this >= 1000000000) return '${(this / 1000000000).toStringAsFixed(1)}B';
    if (this >= 1000000) return '${(this / 1000000).toStringAsFixed(1)}M';
    if (this >= 1000) return '${(this / 1000).toStringAsFixed(1)}K';
    return toStringAsFixed(0);
  }
  // 1500.compact → "1.5K"
  // 2500000.compact → "2.5M"

  // ══════════════════════════════
  // Format phần trăm
  // ══════════════════════════════
  String percent({int decimals = 0}) => '${toStringAsFixed(decimals)}%';
  // 85.5.percent() → "86%"
  // 85.5.percent(decimals: 1) → "85.5%"

  // ══════════════════════════════
  // Format file size
  // ══════════════════════════════
  String get fileSize {
    if (this >= 1073741824)
      return '${(this / 1073741824).toStringAsFixed(1)} GB';
    if (this >= 1048576) return '${(this / 1048576).toStringAsFixed(1)} MB';
    if (this >= 1024) return '${(this / 1024).toStringAsFixed(1)} KB';
    return '${toStringAsFixed(0)} B';
  }
  // 5242880.fileSize → "5.0 MB"

  // ══════════════════════════════
  // Clamp / Range
  // ══════════════════════════════
  bool isBetween(num min, num max) => this >= min && this <= max;

  // ══════════════════════════════
  // Duration helpers
  // ══════════════════════════════
  Duration get milliseconds => Duration(milliseconds: toInt());
  Duration get seconds => Duration(seconds: toInt());
  Duration get minutes => Duration(minutes: toInt());
  Duration get hours => Duration(hours: toInt());
  Duration get days => Duration(days: toInt());
}
