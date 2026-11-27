extension IterableX<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  /// Groups elements by [keyOf], preserving encounter order.
  Map<K, List<T>> groupBy<K>(K Function(T element) keyOf) {
    final result = <K, List<T>>{};
    for (final element in this) {
      (result[keyOf(element)] ??= []).add(element);
    }
    return result;
  }

  /// Removes duplicates by [keyOf] (first occurrence wins).
  List<T> distinctBy<K>(K Function(T element) keyOf) {
    final seen = <K>{};
    return [
      for (final e in this)
        if (seen.add(keyOf(e))) e,
    ];
  }

  /// Splits into lists of at most [size] elements.
  Iterable<List<T>> chunked(int size) sync* {
    assert(size > 0, 'size must be positive');
    var chunk = <T>[];
    for (final element in this) {
      chunk.add(element);
      if (chunk.length == size) {
        yield chunk;
        chunk = <T>[];
      }
    }
    if (chunk.isNotEmpty) yield chunk;
  }

  /// Inserts [separator] between elements (e.g. dividers in a Column).
  Iterable<T> separatedBy(T separator) sync* {
    var first = true;
    for (final element in this) {
      if (!first) yield separator;
      first = false;
      yield element;
    }
  }
}

extension MapX<K, V> on Map<K, V> {
  /// Copy without `null` values – handy for query parameters.
  Map<K, V> get withoutNulls => {
    for (final e in entries)
      if (e.value != null) e.key: e.value,
  };
}
