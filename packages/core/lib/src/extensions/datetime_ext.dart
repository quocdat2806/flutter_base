extension DateTimeExt on DateTime {
  // ══════════════════════════════
  // Format — dùng intl package
  // ══════════════════════════════
  /// 14/11/2026
  String get dateFormatted =>
      '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';

  /// 14:30
  String get timeFormatted =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  /// 14/11/2026 14:30
  String get dateTimeFormatted => '$dateFormatted $timeFormatted';

  /// 2026-11-14
  String get apiFormatted =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  // ══════════════════════════════
  // Time ago — "5 phút trước"
  // ══════════════════════════════
  String timeAgo({String locale = 'vi'}) {
    final diff = DateTime.now().difference(this);

    if (locale == 'vi') return _timeAgoVi(diff);
    return _timeAgoEn(diff);
  }

  String _timeAgoVi(Duration diff) {
    if (diff.inDays > 365) return '${diff.inDays ~/ 365} năm trước';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30} tháng trước';
    if (diff.inDays > 7) return '${diff.inDays ~/ 7} tuần trước';
    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    if (diff.inMinutes > 0) return '${diff.inMinutes} phút trước';
    return 'Vừa xong';
  }

  String _timeAgoEn(Duration diff) {
    if (diff.inDays > 365) return '${diff.inDays ~/ 365}y ago';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays > 7) return '${diff.inDays ~/ 7}w ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  // ══════════════════════════════
  // Comparisons
  // ══════════════════════════════
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  bool get isThisYear {
    return year == DateTime.now().year;
  }

  bool get isPast => isBefore(DateTime.now());
  bool get isFuture => isAfter(DateTime.now());

  // ══════════════════════════════
  // Manipulate
  // ══════════════════════════════

  /// Đầu ngày: 2026-11-14 00:00:00
  DateTime get startOfDay => DateTime(year, month, day);

  /// Cuối ngày: 2026-11-14 23:59:59
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  /// Đầu tháng: 2026-11-01
  DateTime get startOfMonth => DateTime(year, month);

  /// Cuối tháng: 2026-11-30
  DateTime get endOfMonth => DateTime(year, month + 1, 0);

  /// Tuổi
  int get age {
    final now = DateTime.now();
    var age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  // ══════════════════════════════
  // Display smart — "Hôm nay", "Hôm qua", date
  // ══════════════════════════════
  String smartDate({String locale = 'vi'}) {
    if (isToday) return locale == 'vi' ? 'Hôm nay' : 'Today';
    if (isYesterday) return locale == 'vi' ? 'Hôm qua' : 'Yesterday';
    if (isTomorrow) return locale == 'vi' ? 'Ngày mai' : 'Tomorrow';
    if (isThisYear)
      return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}';
    return dateFormatted;
  }

  /// "Hôm nay, 14:30" hoặc "14/11, 14:30"
  String smartDateTime({String locale = 'vi'}) {
    return '${smartDate(locale: locale)}, $timeFormatted';
  }
}
