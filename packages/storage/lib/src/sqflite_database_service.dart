import 'package:core/core.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

/// [DatabaseService] backed by `sqflite` (SQLite on Android / iOS / macOS).
///
/// ```dart
/// final db = await SqfliteDatabaseService.open(
///   name: 'app.db',
///   version: 2,
///   onCreate: (db, version) async {
///     await db.execute('CREATE TABLE notes(id INTEGER PRIMARY KEY, body TEXT)');
///   },
///   onUpgrade: (db, from, to) async {
///     if (from < 2) await db.execute('ALTER TABLE notes ADD COLUMN pinned INTEGER');
///   },
///   onOpen: (db) => db.execute('PRAGMA optimize'),
/// );
/// ```
///
/// Opens with foreign keys enforced and write-ahead logging
/// (`journal_mode=WAL`, `synchronous=NORMAL`): readers don't block the writer
/// and commits are cheaper, while staying safe against app crashes.
final class SqfliteDatabaseService implements DatabaseService {
  SqfliteDatabaseService._(this._executor);

  /// Opens (creating / migrating if needed) the database [name] in the
  /// platform databases directory. Pass `inMemoryDatabasePath` as [name] for
  /// a throwaway database, and [factory] (e.g. `databaseFactoryFfi`) in tests.
  static Future<SqfliteDatabaseService> open({
    required String name,
    required int version,
    required DatabaseCreate onCreate,
    DatabaseUpgrade? onUpgrade,
    DatabaseOpen? onOpen,
    bool foreignKeys = true,
    bool writeAheadLog = true,
    DatabaseFactory? factory,
  }) => guardStorage('SQLite', 'open', name, () async {
    final f = factory ?? databaseFactory;
    final path = name == inMemoryDatabasePath
        ? name
        : p.join(await f.getDatabasesPath(), name);
    final db = await f.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: version,
        onConfigure: (db) async {
          if (foreignKeys) await db.execute('PRAGMA foreign_keys = ON');
          if (writeAheadLog) {
            // journal_mode returns a row, so it must go through rawQuery.
            await db.rawQuery('PRAGMA journal_mode = WAL');
            await db.execute('PRAGMA synchronous = NORMAL');
          }
        },
        onCreate: (db, v) => onCreate(SqfliteDatabaseService._(db), v),
        onUpgrade: onUpgrade == null
            ? null
            : (db, from, to) =>
                  onUpgrade(SqfliteDatabaseService._(db), from, to),
        onOpen: onOpen == null
            ? null
            : (db) => onOpen(SqfliteDatabaseService._(db)),
      ),
    );
    return SqfliteDatabaseService._(db);
  });

  /// Deletes the database file [name] (and its WAL / journal files), e.g. on
  /// sign-out. Close every open [SqfliteDatabaseService] for it first.
  /// Does nothing if the file doesn't exist.
  static Future<void> deleteDatabase(String name, {DatabaseFactory? factory}) =>
      guardStorage('SQLite', 'delete', name, () async {
        final f = factory ?? databaseFactory;
        await f.deleteDatabase(p.join(await f.getDatabasesPath(), name));
      });

  /// Either the [Database] or, inside [transaction], its [Transaction].
  final DatabaseExecutor _executor;

  Future<T> _guard<T>(String op, String target, Future<T> Function() body) =>
      guardStorage(
        'SQLite',
        op,
        target,
        body,
        mapError: (e, message) =>
            e is DatabaseException && e.isUniqueConstraintError()
            ? UniqueConstraintFailure(message)
            : null,
      );

  static ConflictAlgorithm _conflict(ConflictStrategy s) => switch (s) {
    ConflictStrategy.rollback => ConflictAlgorithm.rollback,
    ConflictStrategy.abort => ConflictAlgorithm.abort,
    ConflictStrategy.fail => ConflictAlgorithm.fail,
    ConflictStrategy.ignore => ConflictAlgorithm.ignore,
    ConflictStrategy.replace => ConflictAlgorithm.replace,
  };

  @override
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
  }) => _guard(
    'query',
    table,
    () => _executor.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    ),
  );

  @override
  Future<List<JsonMap>> rawQuery(String sql, [List<Object?>? args]) =>
      _guard('rawQuery', sql, () => _executor.rawQuery(sql, args));

  @override
  Future<int> insert(
    String table,
    JsonMap values, {
    ConflictStrategy conflict = ConflictStrategy.abort,
  }) => _guard(
    'insert',
    table,
    () =>
        _executor.insert(table, values, conflictAlgorithm: _conflict(conflict)),
  );

  @override
  Future<int> update(
    String table,
    JsonMap values, {
    String? where,
    List<Object?>? whereArgs,
  }) => _guard(
    'update',
    table,
    () => _executor.update(table, values, where: where, whereArgs: whereArgs),
  );

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) =>
      _guard(
        'delete',
        table,
        () => _executor.delete(table, where: where, whereArgs: whereArgs),
      );

  @override
  Future<void> execute(String sql, [List<Object?>? args]) =>
      _guard('execute', sql, () => _executor.execute(sql, args));

  @override
  Future<T> transaction<T>(Future<T> Function(DatabaseService txn) action) {
    final executor = _executor;
    // Already inside a transaction: SQLite has no nested transactions, so
    // just run in the current one.
    if (executor is! Database) return action(this);
    return _guard(
      'transaction',
      '*',
      () =>
          executor.transaction((txn) => action(SqfliteDatabaseService._(txn))),
    );
  }

  @override
  Future<void> batch(void Function(DatabaseBatch batch) operations) =>
      _guard('batch', '*', () async {
        final batch = _executor.batch();
        operations(_SqfliteBatch(batch));
        await batch.commit(noResult: true);
      });

  @override
  Future<void> close() async {
    final executor = _executor;
    if (executor is Database) await _guard('close', '*', executor.close);
  }
}

final class _SqfliteBatch implements DatabaseBatch {
  _SqfliteBatch(this._batch);

  final Batch _batch;

  @override
  void insert(
    String table,
    JsonMap values, {
    ConflictStrategy conflict = ConflictStrategy.abort,
  }) => _batch.insert(
    table,
    values,
    conflictAlgorithm: SqfliteDatabaseService._conflict(conflict),
  );

  @override
  void update(
    String table,
    JsonMap values, {
    String? where,
    List<Object?>? whereArgs,
  }) => _batch.update(table, values, where: where, whereArgs: whereArgs);

  @override
  void delete(String table, {String? where, List<Object?>? whereArgs}) =>
      _batch.delete(table, where: where, whereArgs: whereArgs);

  @override
  void execute(String sql, [List<Object?>? args]) => _batch.execute(sql, args);
}
