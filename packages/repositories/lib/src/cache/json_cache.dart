import 'dart:convert';

import 'package:core/core.dart';

import 'cache_policy.dart';

/// Cached value with its write time.
final class CacheEntry<T> {
  const CacheEntry(this.value, this.savedAt);

  final T value;

  /// Show "updated at …" in the UI when serving this while offline.
  final DateTime savedAt;

  bool isFresh(Duration ttl, {DateTime? now}) =>
      (now ?? DateTime.now()).difference(savedAt) < ttl;
}

/// TTL cache of JSON-serialisable values on top of a [CacheStore].
///
/// * `ttl` – how long a value counts as fresh ([CachePolicy.cacheFirst]).
/// * `maxAge` – hard limit; after it the value is gone, even offline. Use
///   [CacheTtl.sensitiveMaxAge] for health data.
///
/// Keys follow [CacheKeys]: user data is wiped on logout, keys starting with
/// [CacheKeys.publicPrefix] are kept.
final class JsonCache {
  JsonCache(this._store, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final CacheStore _store;
  final DateTime Function() _clock;

  int _session = 0;

  /// Current session number. Capture it before a network call and pass it
  /// to [write], so a response that lands after logout isn't stored.
  int get session => _session;

  /// Starts a new session: writes tagged with an older [session] are
  /// dropped. Call right before wiping the cache on logout.
  void resetSession() => _session++;

  Future<CacheEntry<T>?> read<T>(
    String key,
    T Function(Object? json) decode,
  ) async {
    final record = await _store.read(key);
    if (record == null) return null;
    try {
      return CacheEntry(decode(jsonDecode(record.value)), record.savedAt);
    } catch (_) {
      // Schema changed or corrupted → behave as a miss.
      await invalidate(key);
      return null;
    }
  }

  /// Stores [json]. When [session] is given and a logout happened since it
  /// was captured, nothing is written.
  Future<void> write(
    String key,
    Object? json, {
    Duration? maxAge,
    int? session,
  }) async {
    if (session != null && session != _session) return;
    await _store.write(key, jsonEncode(json), maxAge: maxAge);
  }

  Future<void> invalidate(String key) => _store.remove(key);

  /// Drops every key starting with [prefix], e.g. `'appointment.'`.
  Future<void> invalidatePrefix(String prefix) =>
      _store.removeWhere(prefix: prefix);

  /// Applies [policy] to a single read.
  ///
  /// * [fetch] loads from the network (throws [AppException]).
  /// * [encode] / [decode] convert between the model and JSON.
  Future<T> fetch<T>({
    required String key,
    required Future<T> Function() fetch,
    required Object? Function(T value) encode,
    required T Function(Object? json) decode,
    CachePolicy policy = CachePolicy.networkFirst,
    Duration ttl = const Duration(minutes: 5),
    Duration? maxAge,
  }) async {
    Future<T> fetchAndStore() async {
      final session = _session;
      final value = await fetch();
      await write(key, encode(value), maxAge: maxAge, session: session);
      return value;
    }

    switch (policy) {
      case CachePolicy.networkOnly:
        return fetchAndStore();

      case CachePolicy.cacheOnly:
        final cached = await read(key, decode);
        if (cached == null) {
          throw StorageException('No cached value for "$key"');
        }
        return cached.value;

      case CachePolicy.cacheFirst:
        final cached = await read(key, decode);
        if (cached != null && cached.isFresh(ttl, now: _clock())) {
          return cached.value;
        }
        try {
          return await fetchAndStore();
        } on AppException catch (e) {
          if (cached != null && _isOfflineError(e)) return cached.value;
          rethrow;
        }

      case CachePolicy.networkFirst:
        try {
          return await fetchAndStore();
        } on AppException catch (e) {
          if (!_isOfflineError(e)) rethrow;
          final cached = await read(key, decode);
          if (cached == null) rethrow;
          return cached.value;
        }
    }
  }

  /// Only fall back to cache for connectivity problems – never mask auth or
  /// validation errors with stale data.
  static bool _isOfflineError(AppException e) => switch (e) {
    NetworkException() || RequestTimeoutException() => true,
    ServerException(:final statusCode) => statusCode >= 500,
    _ => false,
  };
}
