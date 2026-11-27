import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// [SecureStorage] backed by `flutter_secure_storage`
/// (Keychain on iOS, Keystore-encrypted on Android).
///
/// Use for tokens, PINs and anything that identifies the user. The platform
/// only stores strings, so every value is saved JSON-encoded and decoded back
/// to its type on [get].
///
/// An optional [namespace] prefixes every key, and limits [clear] to this
/// service's own keys. Without one, [clear] wipes the app's whole secure
/// store.
final class SecureStorageService implements SecureStorage {
  SecureStorageService({FlutterSecureStorage? storage, this.namespace})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            iOptions: IOSOptions(
              // Readable after first unlock so background refresh works,
              // but never migrated to a new device via backup.
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  final FlutterSecureStorage _storage;
  final String? namespace;

  String _k(String key) => namespace == null ? key : '$namespace.$key';

  /// Wipes the **whole** secure store (every namespace) the first time the
  /// app runs after an install, then records that in [prefs] under [flagKey].
  /// Returns `true` when a wipe happened.
  ///
  /// iOS keeps Keychain items when the app is uninstalled, so without this a
  /// reinstall would silently sign the previous user back in. Preferences
  /// *are* removed on uninstall, which is what makes the flag reliable.
  /// Call once at startup, before anything reads secrets.
  ///
  /// Note: the first release that ships this also wipes once for existing
  /// users (they have no flag yet), signing them out.
  Future<bool> clearIfFreshInstall(
    StorageService prefs, {
    String flagKey = 'storage.secure_initialized',
  }) => _guard('clear', '*', () async {
    if (await prefs.get<bool>(flagKey) ?? false) return false;
    await _storage.deleteAll();
    await prefs.set(flagKey, true);
    return true;
  });

  Future<T> _guard<T>(String op, String key, Future<T> Function() body) =>
      guardStorage('Secure', op, key, body);

  @override
  Future<T?> get<T>(String key) => _guard('read', key, () async {
    final raw = await _storage.read(key: _k(key));
    if (raw == null) return null;
    try {
      return coerceStorageValue<T>(jsonDecode(raw));
    } on FormatException {
      // Not written by this service (plain text): only readable as a String.
      return coerceStorageValue<T>(raw);
    }
  });

  @override
  Future<void> set<T extends Object>(String key, T value) =>
      _guard('write', key, () {
        checkStorageValue(key, value);
        return _storage.write(key: _k(key), value: jsonEncode(value));
      });

  @override
  Future<bool> containsKey(String key) =>
      _guard('read', key, () => _storage.containsKey(key: _k(key)));

  @override
  Future<void> remove(String key) =>
      _guard('remove', key, () => _storage.delete(key: _k(key)));

  @override
  Future<void> clear({Set<String>? allowList}) =>
      _guard('clear', '*', () async {
        final Iterable<String> keys;
        if (allowList != null) {
          keys = allowList.map(_k);
        } else if (namespace == null) {
          return _storage.deleteAll();
        } else {
          // Only wipe keys that belong to this namespace.
          final all = await _storage.readAll();
          keys = all.keys.where((k) => k.startsWith('$namespace.')).toList();
        }
        for (final key in keys) {
          await _storage.delete(key: key);
        }
      });
}
