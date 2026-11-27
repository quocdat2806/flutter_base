import 'package:intl/intl.dart';

import '../extensions/date_time_extensions.dart';

/// Locale-aware date formatting. Call `initializeDateFormatting('vi')`
/// (from `package:intl/date_symbol_data_local.dart`) once at app start
/// before using a non-English [locale].
abstract final class DateFormatter {
  static const defaultLocale = 'vi';

  /// `14/11/2026`.
  static String date(DateTime d, {String locale = defaultLocale}) =>
      DateFormat('dd/MM/yyyy', locale).format(d);

  /// `14:05`.
  static String time(DateTime d, {String locale = defaultLocale}) =>
      DateFormat('HH:mm', locale).format(d);

  /// `14:05 14/11/2026`.
  static String dateTime(DateTime d, {String locale = defaultLocale}) =>
      DateFormat('HH:mm dd/MM/yyyy', locale).format(d);

  /// ISO-8601 date only (`2026-11-14`) for API payloads.
  static String apiDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  /// Human relative label used in chat / notifications.
  ///
  /// Labels are Vietnamese by default; override via [labels].
  static String relative(
    DateTime d, {
    DateTime? now,
    RelativeLabels labels = const RelativeLabels(),
    String locale = defaultLocale,
  }) {
    final ref = now ?? DateTime.now();
    final diff = ref.difference(d);
    if (diff.isNegative) return dateTime(d, locale: locale);
    if (diff.inSeconds < 60) return labels.justNow;
    if (diff.inMinutes < 60) return labels.minutesAgo(diff.inMinutes);
    if (d.isSameDay(ref)) return labels.hoursAgo(diff.inHours);
    if (d.isSameDay(ref.subtract(const Duration(days: 1)))) {
      return '${labels.yesterday} ${time(d, locale: locale)}';
    }
    if (diff.inDays < 7) return labels.daysAgo(diff.inDays);
    return date(d, locale: locale);
  }
}

/// Strings used by [DateFormatter.relative].
class RelativeLabels {
  const RelativeLabels({
    this.justNow = 'Vừa xong',
    this.yesterday = 'Hôm qua',
    this.minutesSuffix = 'phút trước',
    this.hoursSuffix = 'giờ trước',
    this.daysSuffix = 'ngày trước',
  });

  final String justNow;
  final String yesterday;
  final String minutesSuffix;
  final String hoursSuffix;
  final String daysSuffix;

  String minutesAgo(int n) => '$n $minutesSuffix';
  String hoursAgo(int n) => '$n $hoursSuffix';
  String daysAgo(int n) => '$n $daysSuffix';
}
