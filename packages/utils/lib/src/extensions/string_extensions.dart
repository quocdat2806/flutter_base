const _vnFrom =
    'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ'
    'ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ';
const _vnTo =
    'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd'
    'AAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';

final Map<String, String> _vnMap = {
  for (var i = 0; i < _vnFrom.length; i++) _vnFrom[i]: _vnTo[i],
};

extension StringX on String {
  /// `true` when empty or whitespace only.
  bool get isBlank => trim().isEmpty;
  bool get isNotBlank => !isBlank;

  /// `"hello world"` → `"Hello world"`.
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// `"nguyễn văn a"` → `"Nguyễn Văn A"`.
  String get titleCase => split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .map((w) => w.toLowerCase().capitalized)
      .join(' ');

  /// Strips Vietnamese diacritics: `"Đặng Thị Hà"` → `"Dang Thi Ha"`.
  /// Use for accent-insensitive search and slugs.
  String get withoutDiacritics {
    final buffer = StringBuffer();
    for (final rune in runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_vnMap[char] ?? char);
    }
    return buffer.toString();
  }

  /// Lower-cased, accent-free form for search comparisons.
  String get searchable => withoutDiacritics.toLowerCase().trim();

  /// Case- and accent-insensitive `contains`.
  bool containsIgnoringAccents(String query) =>
      searchable.contains(query.searchable);

  /// Initials for avatars: `"Nguyễn Văn An"` → `"NA"`.
  String initials({int max = 2}) {
    final parts = trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '';
    if (parts.length == 1 || max == 1) {
      return parts.first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Masks all but the last [visible] characters: `"0912345678"` → `"******5678"`.
  String masked({int visible = 4, String mask = '*'}) => length <= visible
      ? this
      : '${mask * (length - visible)}${substring(length - visible)}';

  /// Truncates with an ellipsis when longer than [maxLength].
  String ellipsis(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength).trimRight()}…';
}

extension NullableStringX on String? {
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;

  /// `null` for blank strings – useful when sending optional form fields.
  String? get nullIfBlank => isNullOrBlank ? null : this!.trim();
}
