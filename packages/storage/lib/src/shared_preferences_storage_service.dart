import 'package:core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [StorageService] backed by `shared_preferences` (`SharedPreferencesAsync`).
///
/// Not encrypted – never store tokens or PII here. An optional [namespace]
/// prefixes every key so several features can share the platform store, and
/// limits [clear] to this service's own keys. Without one, [clear] wipes
/// every preference of the app.
final class SharedPreferencesStorageService implements StorageService {
  SharedPreferencesStorageService({
    SharedPreferencesAsync? prefs,
    this.namespace,
  }) : _prefs = prefs ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;
  final String? namespace;

  String _k(String key) => namespace == null ? key : '$namespace.$key';

  Future<T> _guard<T>(String op, String key, Future<T> Function() body) =>
      guardStorage('Prefs', op, key, body);

  @override
  Future<T?> get<T>(String key) => _guard('read', key, () async {
    final k = _k(key);
    final all = await _prefs.getAll(allowList: {k});
    return coerceStorageValue<T>(all[k]);
  });

  @override
  Future<void> set<T extends Object>(String key, T value) {
    final k = _k(key);
    return _guard('write', key, () {
      checkStorageValue(key, value);
      return switch (value) {
        final String v => _prefs.setString(k, v),
        final bool v => _prefs.setBool(k, v),
        final int v => _prefs.setInt(k, v),
        final double v => _prefs.setDouble(k, v),
        final List<String> v => _prefs.setStringList(k, v),
        _ => throw StateError('unreachable'),
      };
    });
  }

  @override
  Future<bool> containsKey(String key) =>
      _guard('read', key, () => _prefs.containsKey(_k(key)));

  @override
  Future<void> remove(String key) =>
      _guard('remove', key, () => _prefs.remove(_k(key)));

  @override
  Future<void> clear({Set<String>? allowList}) =>
      _guard('clear', '*', () async {
        if (allowList != null) {
          return _prefs.clear(allowList: allowList.map(_k).toSet());
        }
        if (namespace == null) return _prefs.clear();
        // Only wipe keys that belong to this namespace.
        final keys = await _prefs.getKeys();
        final owned = keys.where((k) => k.startsWith('$namespace.')).toSet();
        if (owned.isNotEmpty) await _prefs.clear(allowList: owned);
      });
}
