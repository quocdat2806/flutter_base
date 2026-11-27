extension MapExt<K, V> on Map<K, V> {
  /// Lấy value an toàn, trả default nếu key không tồn tại.
  V getOr(K key, V defaultValue) => this[key] ?? defaultValue;

  /// Lọc map theo condition.
  Map<K, V> whereEntries(bool Function(K key, V value) test) {
    return Map.fromEntries(entries.where((e) => test(e.key, e.value)));
  }

  /// Bỏ các entries có value null.
  Map<K, V> get withoutNulls {
    return Map.fromEntries(entries.where((e) => e.value != null));
  }

  /// Merge với map khác, map kia ưu tiên.
  Map<K, V> mergeWith(Map<K, V> other) => {...this, ...other};
}

extension JsonMapExt on Map<String, dynamic> {
  /// Parse an toàn — không throw nếu key thiếu hoặc sai type.
  String? getString(String key) => this[key] as String?;
  int? getInt(String key) => this[key] as int?;
  double? getDouble(String key) {
    final value = this[key];
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  bool? getBool(String key) => this[key] as bool?;
  List<dynamic>? getList(String key) => this[key] as List<dynamic>?;
  Map<String, dynamic>? getMap(String key) =>
      this[key] as Map<String, dynamic>?;

  /// Nested access: json.getNested('user.address.city')
  dynamic getNested(String path) {
    final keys = path.split('.');
    dynamic current = this;
    for (final key in keys) {
      if (current is Map<String, dynamic>) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current;
  }
}
