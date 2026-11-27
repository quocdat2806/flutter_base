import 'package:core/core.dart';

/// How [DatabaseService.insert] resolves a primary-key / unique conflict.
enum ConflictStrategy { rollback, abort, fail, ignore, replace }

/// Called inside the open transaction to create or migrate the schema.
typedef DatabaseCreate = Future<void> Function(DatabaseService db, int version);
typedef DatabaseUpgrade =
    Future<void> Function(DatabaseService db, int oldVersion, int newVersion);

/// Called every time the database has been opened (after create / upgrade).
/// Good place for seeding checks, `PRAGMA optimize` or maintenance.
typedef DatabaseOpen = Future<void> Function(DatabaseService db);

/// Write operations queued by [DatabaseService.batch].
abstract interface class DatabaseBatch {
  void insert(
    String table,
    JsonMap values, {
    ConflictStrategy conflict = ConflictStrategy.abort,
  });

  void update(
    String table,
    JsonMap values, {
    String? where,
    List<Object?>? whereArgs,
  });

  void delete(String table, {String? where, List<Object?>? whereArgs});

  void execute(String sql, [List<Object?>? args]);
}

/// Relational local database (structured data, lists, offline cache that
/// needs querying).
///
/// Implemented by [SqfliteDatabaseService]. Rows are plain `Map`s; map them to
/// models in the repository layer. Failures surface as [CacheFailure].
abstract interface class DatabaseService {
  Future<List<JsonMap>> query(
    String table, {
    bool distinct = false,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  });

  Future<List<JsonMap>> rawQuery(String sql, [List<Object?>? args]);

  /// Returns the row id of the inserted row.
  Future<int> insert(
    String table,
    JsonMap values, {
    ConflictStrategy conflict = ConflictStrategy.abort,
  });

  /// Returns the number of rows changed.
  Future<int> update(
    String table,
    JsonMap values, {
    String? where,
    List<Object?>? whereArgs,
  });

  /// Returns the number of rows deleted.
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs});

  /// Runs a statement that returns nothing (DDL, PRAGMA…).
  Future<void> execute(String sql, [List<Object?>? args]);

  /// Runs [action] atomically: everything commits or nothing does.
  /// Use the `txn` passed in, not the outer service, inside [action].
  Future<T> transaction<T>(Future<T> Function(DatabaseService txn) action);

  /// Queues the writes added in [operations] and sends them to SQLite in one
  /// round trip, atomically. Much faster than awaiting each write when
  /// inserting many rows (seeding, syncing a page of results).
  Future<void> batch(void Function(DatabaseBatch batch) operations);

  Future<void> close();
}
