import 'package:intl/intl.dart';

/// Money formatting. Defaults to VND (no decimals, `₫` suffix).
abstract final class CurrencyFormatter {
  static final _vnd = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );
  static final _compact = NumberFormat.compact(locale: 'vi_VN');
  static final _decimal = NumberFormat.decimalPattern('vi_VN');

  /// `150000` → `150.000 ₫`.
  static String vnd(num amount) => _vnd.format(amount);

  /// `150000` → `150.000` (no symbol, for inputs and tables).
  static String plain(num amount) => _decimal.format(amount);

  /// `1500000` → `1,5 Tr`.
  static String compact(num amount) => _compact.format(amount);

  /// Parses user input like `"150.000 ₫"` back to a number. Returns `null`
  /// when nothing numeric remains.
  static int? parse(String input) {
    final digits = input.replaceAll(RegExp(r'[^\d-]'), '');
    return digits.isEmpty ? null : int.tryParse(digits);
  }
}
