import 'package:core/core.dart';

import 'database_service.dart';

/// [CacheStore] backed by the `cache` table of a [DatabaseService].
///
/// Create the table from the database's `onCreate` / `onUpgrade` with
/// [createTable] (see `openAppDatabase`).
final class SqfliteCacheStore implements CacheStore {
  SqfliteCacheStore(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DatabaseService _db;
  final DateTime Function() _clock;

  static const table = 'cache';

  static Future<void> createTable(DatabaseService db) async {
    await db.execute('''
      CREATE TABLE $table (
        key        TEXT PRIMARY KEY,
        value      TEXT NOT NULL,
        saved_at   INTEGER NOT NULL,
        expires_at INTEGER
      )''');
    await db.execute('CREATE INDEX idx_cache_expires ON $table(expires_at)');
  }

  int get _now => _clock().millisecondsSinceEpoch;

  @override
  Future<CacheRecord?> read(String key) async {
    final rows = await _db.query(
      table,
      where: 'key = ? AND (expires_at IS NULL OR expires_at > ?)',
      whereArgs: [key, _now],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    final expiresAt = row['expires_at'] as int?;
    return CacheRecord(
      value: row['value'] as String,
      savedAt: DateTime.fromMillisecondsSinceEpoch(row['saved_at'] as int),
      expiresAt: expiresAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(expiresAt),
    );
  }

  @override
  Future<void> write(String key, String value, {Duration? maxAge}) {
    final now = _now;
    return _db.insert(table, {
      'key': key,
      'value': value,
      'saved_at': now,
      'expires_at': maxAge == null ? null : now + maxAge.inMilliseconds,
    }, conflict: ConflictStrategy.replace);
  }

  @override
  Future<void> remove(String key) =>
      _db.delete(table, where: 'key = ?', whereArgs: [key]);

  @override
  Future<void> removeWhere({required String prefix}) => _db.delete(
    table,
    where: r"key LIKE ? ESCAPE '\'",
    whereArgs: ['${_escapeLike(prefix)}%'],
  );

  @override
  Future<void> clear({String? keepPrefix}) => keepPrefix == null
      ? _db.delete(table)
      : _db.delete(
          table,
          where: r"key NOT LIKE ? ESCAPE '\'",
          whereArgs: ['${_escapeLike(keepPrefix)}%'],
        );

  @override
  Future<int> purgeExpired() => _db.delete(
    table,
    where: 'expires_at IS NOT NULL AND expires_at <= ?',
    whereArgs: [_now],
  );

  static String _escapeLike(String s) =>
      s.replaceAllMapped(RegExp(r'[\\%_]'), (m) => '\\${m[0]}');
}
