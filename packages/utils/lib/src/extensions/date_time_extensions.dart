extension DateTimeX on DateTime {
  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);
  DateTime get startOfMonth => DateTime(year, month);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool get isToday => isSameDay(DateTime.now());
  bool get isYesterday =>
      isSameDay(DateTime.now().subtract(const Duration(days: 1)));
  bool get isTomorrow => isSameDay(DateTime.now().add(const Duration(days: 1)));

  /// Whole years between this birth date and [at] (defaults to now).
  int age({DateTime? at}) {
    final now = at ?? DateTime.now();
    var years = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) years--;
    return years;
  }

  /// Number of calendar days from this date to [other] (DST-safe).
  int daysUntil(DateTime other) => DateTime.utc(
    other.year,
    other.month,
    other.day,
  ).difference(DateTime.utc(year, month, day)).inDays;
}
