/// Vietnamese phone number helpers.
abstract final class PhoneFormatter {
  /// Mobile prefixes after the leading 0 (Viettel, Vina, Mobi, Vietnamobile,
  /// Gmobile, Itel, Reddi).
  static final _vnMobile = RegExp(r'^0(3|5|7|8|9)\d{8}$');
  static final _nonDigit = RegExp(r'[^\d+]');

  /// Normalizes to local form: `+84 912-345-678` → `0912345678`.
  static String toLocal(String input) {
    var v = input.replaceAll(_nonDigit, '');
    if (v.startsWith('+84')) {
      v = '0${v.substring(3)}';
    } else if (v.startsWith('84') && v.length == 11) {
      v = '0${v.substring(2)}';
    }
    return v;
  }

  /// E.164: `0912345678` → `+84912345678`. Use when talking to the backend
  /// or SMS gateways.
  static String toE164(String input) {
    final local = toLocal(input);
    return local.startsWith('0') ? '+84${local.substring(1)}' : local;
  }

  static bool isValidVnMobile(String input) =>
      _vnMobile.hasMatch(toLocal(input));

  /// Display form: `0912345678` → `0912 345 678`.
  static String display(String input) {
    final v = toLocal(input);
    if (v.length != 10) return input;
    return '${v.substring(0, 4)} ${v.substring(4, 7)} ${v.substring(7)}';
  }
}
