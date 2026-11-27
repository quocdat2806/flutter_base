import 'dart:convert';

import 'package:core/core.dart';
import 'package:storage/storage.dart';

import '../models/auth_tokens.dart';

/// Persists [AuthTokens] across launches.
abstract interface class TokenStorage {
  Future<AuthTokens?> read();
  Future<void> save(AuthTokens tokens);
  Future<void> clear();
}

/// Stores tokens as one JSON blob in encrypted storage. Requires a
/// [SecureStorage], so a plain-text store can't be passed by mistake.
final class SecureTokenStorage implements TokenStorage {
  const SecureTokenStorage(this._store, {this.key = 'auth.tokens'});

  final SecureStorage _store;
  final String key;

  @override
  Future<AuthTokens?> read() async {
    final raw = await _store.get<String>(key);
    if (raw == null) return null;
    try {
      return AuthTokens.fromJson(jsonDecode(raw) as JsonMap);
    } catch (_) {
      // Corrupt or legacy format → treat as signed out.
      await _store.remove(key);
      return null;
    }
  }

  @override
  Future<void> save(AuthTokens tokens) =>
      _store.set(key, jsonEncode(tokens.toJson()));

  @override
  Future<void> clear() => _store.remove(key);
}
