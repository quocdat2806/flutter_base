extension DurationExt on Duration {
  /// 1:30:00
  String get formatted {
    final h = inHours;
    final m = inMinutes.remainder(60);
    final s = inSeconds.remainder(60);

    if (h > 0)
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// "2 giờ 30 phút"
  String display({String locale = 'vi'}) {
    if (locale == 'vi') return _displayVi();
    return _displayEn();
  }

  String _displayVi() {
    if (inDays > 0) return '$inDays ngày ${inHours.remainder(24)} giờ';
    if (inHours > 0) return '$inHours giờ ${inMinutes.remainder(60)} phút';
    if (inMinutes > 0) return '$inMinutes phút';
    return '$inSeconds giây';
  }

  String _displayEn() {
    if (inDays > 0) return '${inDays}d ${inHours.remainder(24)}h';
    if (inHours > 0) return '${inHours}h ${inMinutes.remainder(60)}m';
    if (inMinutes > 0) return '${inMinutes}m';
    return '${inSeconds}s';
  }

  /// "15:00" countdown timer format.
  String get countdown {
    final m = inMinutes.remainder(60);
    final s = inSeconds.remainder(60);
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
