/// One cached JSON value as stored by a [CacheStore].
final class CacheRecord {
  const CacheRecord({
    required this.value,
    required this.savedAt,
    this.expiresAt,
  });

  /// JSON-encoded payload.
  final String value;
  final DateTime savedAt;

  /// Hard deadline after which the record is never returned. `null` keeps it
  /// until it is removed (e.g. on logout).
  final DateTime? expiresAt;
}

/// Storage backend for the JSON cache used by repositories.
///
/// Implemented by `SqfliteCacheStore` (mobile / desktop) and
/// `MemoryCacheStore` (web, tests). Freshness (`ttl`) is decided by the
/// caller; the store only enforces the hard [CacheRecord.expiresAt].
/// Backend failures surface as `CacheFailure`.
abstract interface class CacheStore {
  /// Returns `null` when [key] is missing or past its `expiresAt`.
  /// Does not delete expired rows – see [purgeExpired].
  Future<CacheRecord?> read(String key);

  /// Stores [value] (JSON string) under [key], replacing any previous value.
  /// [maxAge] sets the hard expiry; `null` keeps it until removed.
  Future<void> write(String key, String value, {Duration? maxAge});

  Future<void> remove(String key);

  /// Removes every key starting with [prefix], e.g. `'appointment.'`.
  Future<void> removeWhere({required String prefix});

  /// Removes every key, except those starting with [keepPrefix] when given.
  Future<void> clear({String? keepPrefix});

  /// Deletes rows past their `expiresAt`. Returns how many were deleted.
  Future<int> purgeExpired();
}
