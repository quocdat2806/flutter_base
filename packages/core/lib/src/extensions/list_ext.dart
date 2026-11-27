extension ListExt<T> on List<T> {
  /// Lấy phần tử theo index, null nếu out of range.
  T? getOrNull(int index) => index >= 0 && index < length ? this[index] : null;

  /// Chia list thành các chunks.
  /// [1,2,3,4,5].chunked(2) → [[1,2], [3,4], [5]]
  List<List<T>> chunked(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      final end = (i + size > length) ? length : i + size;
      chunks.add(sublist(i, end));
    }
    return chunks;
  }

  /// Loại bỏ duplicates theo key.
  /// users.uniqueBy((u) => u.id)
  List<T> uniqueBy<K>(K Function(T element) key) {
    final seen = <K>{};
    return where((element) => seen.add(key(element))).toList();
  }

  /// Tìm phần tử hoặc null.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  /// Sort mà không mutate list gốc.
  List<T> sortedBy(Comparable Function(T element) key) {
    final copy = [...this];
    copy.sort((a, b) => key(a).compareTo(key(b)));
    return copy;
  }

  /// Sort giảm dần.
  List<T> sortedByDescending(Comparable Function(T element) key) {
    final copy = [...this];
    copy.sort((a, b) => key(b).compareTo(key(a)));
    return copy;
  }

  /// Tính tổng theo field.
  /// orders.sumBy((o) => o.totalAmount)
  double sumBy(num Function(T element) selector) {
    return fold(0.0, (sum, element) => sum + selector(element));
  }

  /// Group theo key.
  /// products.groupBy((p) => p.categoryId)
  Map<K, List<T>> groupBy<K>(K Function(T element) key) {
    final map = <K, List<T>>{};
    for (final element in this) {
      final k = key(element);
      (map[k] ??= []).add(element);
    }
    return map;
  }

  /// Xen kẽ separator giữa các phần tử.
  /// [1,2,3].separated(0) → [1,0,2,0,3]
  List<T> separated(T separator) {
    if (length <= 1) return [...this];
    final result = <T>[];
    for (var i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) result.add(separator);
    }
    return result;
  }
}

extension NullableListExt<T> on List<T>? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
}
