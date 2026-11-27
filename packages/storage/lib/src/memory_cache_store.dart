import 'package:core/core.dart';

/// In-memory [CacheStore] for the web build (no sqflite) and tests.
/// Same semantics as `SqfliteCacheStore`; nothing survives a restart.
final class MemoryCacheStore implements CacheStore {
  MemoryCacheStore({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final _records = <String, CacheRecord>{};

  bool _expired(CacheRecord r) {
    final expiresAt = r.expiresAt;
    return expiresAt != null && !expiresAt.isAfter(_clock());
  }

  @override
  Future<CacheRecord?> read(String key) async {
    final r = _records[key];
    return r == null || _expired(r) ? null : r;
  }

  @override
  Future<void> write(String key, String value, {Duration? maxAge}) async {
    final now = _clock();
    _records[key] = CacheRecord(
      value: value,
      savedAt: now,
      expiresAt: maxAge == null ? null : now.add(maxAge),
    );
  }

  @override
  Future<void> remove(String key) async => _records.remove(key);

  @override
  Future<void> removeWhere({required String prefix}) async =>
      _records.removeWhere((k, _) => k.startsWith(prefix));

  @override
  Future<void> clear({String? keepPrefix}) async => keepPrefix == null
      ? _records.clear()
      : _records.removeWhere((k, _) => !k.startsWith(keepPrefix));

  @override
  Future<int> purgeExpired() async {
    final before = _records.length;
    _records.removeWhere((_, r) => _expired(r));
    return before - _records.length;
  }
}
