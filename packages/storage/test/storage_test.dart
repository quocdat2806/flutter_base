import 'package:core/core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:storage/storage.dart';

/// Same behaviour contract for every [StorageService] implementation.
void contract(String name, Future<StorageService> Function() create) {
  group(name, () {
    late StorageService s;
    setUp(() async => s = await create());

    test('typed round-trips', () async {
      await s.set('s', 'xin chào');
      await s.set('b', true);
      await s.set('i', 42);
      await s.set('d', 1.5);
      await s.set('l', ['a', 'b']);
      expect(await s.get<String>('s'), 'xin chào');
      expect(await s.get<bool>('b'), isTrue);
      expect(await s.get<int>('i'), 42);
      expect(await s.get<double>('d'), 1.5);
      expect(await s.get<List<String>>('l'), ['a', 'b']);
    });

    test('missing keys return null', () async {
      expect(await s.get<String>('none'), isNull);
      expect(await s.get<int>('none'), isNull);
      expect(await s.containsKey('none'), isFalse);
    });

    test('remove and clear(allowList)', () async {
      await s.set('a', 1);
      await s.set('b', 2);
      await s.set('c', 3);
      await s.remove('a');
      expect(await s.containsKey('a'), isFalse);
      await s.clear(allowList: {'b'});
      expect(await s.containsKey('b'), isFalse);
      expect(await s.containsKey('c'), isTrue);
      await s.clear();
      expect(await s.containsKey('c'), isFalse);
    });

    test('wrong type returns null, int widens to double', () async {
      await s.set('i', 3);
      expect(await s.get<String>('i'), isNull);
      expect(await s.get<double>('i'), 3.0);
    });

    test('unsupported type is rejected', () async {
      await expectLater(s.set('x', DateTime(2026)), throwsArgumentError);
    });

    test('json helpers', () async {
      await s.setJson('j', {'a': 1, 'b': 'x'});
      expect(await s.getJson('j'), {'a': 1, 'b': 'x'});
      expect(await s.getObject('j', (json) => json['b']), 'x');
    });

    test('json that is not an object is treated as corrupted', () async {
      await s.set('j', '[1, 2]');
      await expectLater(s.getJson('j'), throwsA(isA<CacheFailure>()));
      expect(await s.containsKey('j'), isFalse);
    });

    test('corrupted json is removed and reported', () async {
      await s.set('j', '{oops');
      await expectLater(s.getJson('j'), throwsA(isA<CacheFailure>()));
      expect(await s.containsKey('j'), isFalse);
    });
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  contract('SharedPreferencesStorageService', () async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    return SharedPreferencesStorageService(namespace: 'test');
  });

  contract('SecureStorageService', () async {
    FlutterSecureStorage.setMockInitialValues({});
    return SecureStorageService();
  });

  test('SecureStorage namespace isolates clear()', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final a = SecureStorageService(namespace: 'a');
    final b = SecureStorageService(namespace: 'b');
    await a.set('k', 1);
    await b.set('k', 2);
    await a.clear();
    expect(await a.get<int>('k'), isNull);
    expect(await b.get<int>('k'), 2);
  });

  test('clearIfFreshInstall wipes secrets once per install', () async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    final prefs = SharedPreferencesStorageService();
    final secure = SecureStorageService(namespace: 'auth');

    // Leftover from a previous install (Keychain survives uninstall).
    await secure.set('token', 'old');
    expect(await secure.clearIfFreshInstall(prefs), isTrue);
    expect(await secure.get<String>('token'), isNull);

    // Later launches keep what was stored.
    await secure.set('token', 'new');
    expect(await secure.clearIfFreshInstall(prefs), isFalse);
    expect(await secure.get<String>('token'), 'new');
  });

  test('SharedPreferences namespace isolates clear()', () async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    final a = SharedPreferencesStorageService(namespace: 'a');
    final b = SharedPreferencesStorageService(namespace: 'b');
    await a.set('k', 1);
    await b.set('k', 2);
    await a.clear();
    expect(await a.get<int>('k'), isNull);
    expect(await b.get<int>('k'), 2);
  });

  group('SqfliteDatabaseService', () {
    sqfliteFfiInit();
    late DatabaseService db;

    setUp(() async {
      db = await SqfliteDatabaseService.open(
        name: inMemoryDatabasePath,
        version: 1,
        factory: databaseFactoryFfi,
        onCreate: (db, _) => db.execute(
          'CREATE TABLE notes(id INTEGER PRIMARY KEY, body TEXT NOT NULL)',
        ),
      );
    });
    tearDown(() => db.close());

    test('insert, query, update, delete', () async {
      final id = await db.insert('notes', {'body': 'a'});
      expect(await db.query('notes'), [
        {'id': id, 'body': 'a'},
      ]);
      expect(
        await db.update(
          'notes',
          {'body': 'b'},
          where: 'id = ?',
          whereArgs: [id],
        ),
        1,
      );
      expect((await db.query('notes')).single['body'], 'b');
      expect(await db.delete('notes', where: 'id = ?', whereArgs: [id]), 1);
      expect(await db.query('notes'), isEmpty);
    });

    test('conflict strategy', () async {
      await db.insert('notes', {'id': 1, 'body': 'a'});
      await expectLater(
        db.insert('notes', {'id': 1, 'body': 'b'}),
        throwsA(isA<UniqueConstraintFailure>()),
      );
      // Other constraint failures stay plain CacheFailures.
      await expectLater(
        db.insert('notes', {'body': null}),
        throwsA(
          isA<CacheFailure>().having(
            (e) => e is UniqueConstraintFailure,
            'is unique violation',
            isFalse,
          ),
        ),
      );
      await db.insert('notes', {
        'id': 1,
        'body': 'b',
      }, conflict: ConflictStrategy.replace);
      expect((await db.query('notes')).single['body'], 'b');
    });

    test('transaction rolls back on error', () async {
      await expectLater(
        db.transaction((txn) async {
          await txn.insert('notes', {'body': 'x'});
          throw StateError('boom');
        }),
        throwsA(isA<CacheFailure>()),
      );
      expect(await db.query('notes'), isEmpty);
    });

    test('Failure thrown inside a transaction is not rewrapped', () async {
      await expectLater(
        db.transaction((txn) async {
          await txn.insert('notes', {'body': 'x'});
          throw const UnauthorizedFailure();
        }),
        throwsA(isA<UnauthorizedFailure>()),
      );
      expect(await db.query('notes'), isEmpty);
    });

    test('batch writes all rows atomically', () async {
      await db.batch((b) {
        for (var i = 0; i < 50; i++) {
          b.insert('notes', {'body': 'n$i'});
        }
        b.delete('notes', where: 'body = ?', whereArgs: ['n0']);
      });
      expect(await db.query('notes'), hasLength(49));

      await expectLater(
        db.batch((b) {
          b.insert('notes', {'body': 'ok'});
          b.insert('notes', {'body': null}); // NOT NULL violation
        }),
        throwsA(isA<CacheFailure>()),
      );
      expect(await db.query('notes'), hasLength(49));
    });

    test('onOpen runs on every open; WAL and foreign keys are on', () async {
      final factory = databaseFactoryFfi;
      final path = '${await factory.getDatabasesPath()}/open_test.db';
      await factory.deleteDatabase(path);
      var opens = 0;
      Future<DatabaseService> open() => SqfliteDatabaseService.open(
        name: 'open_test.db',
        version: 1,
        factory: factory,
        onCreate: (db, _) async {},
        onOpen: (db) async => opens++,
      );
      final first = await open();
      expect(
        (await first.rawQuery('PRAGMA journal_mode')).single.values.single,
        'wal',
      );
      expect(
        (await first.rawQuery('PRAGMA foreign_keys')).single.values.single,
        1,
      );
      await first.close();
      await (await open()).close();
      expect(opens, 2);
      await factory.deleteDatabase(path);
    });

    test('deleteDatabase removes the file', () async {
      final factory = databaseFactoryFfi;
      final path = '${await factory.getDatabasesPath()}/delete_test.db';
      final opened = await SqfliteDatabaseService.open(
        name: 'delete_test.db',
        version: 1,
        factory: factory,
        onCreate: (db, _) async {},
      );
      await opened.close();
      expect(await factory.databaseExists(path), isTrue);
      await SqfliteDatabaseService.deleteDatabase(
        'delete_test.db',
        factory: factory,
      );
      expect(await factory.databaseExists(path), isFalse);
    });

    test('onUpgrade migrates schema', () async {
      final factory = databaseFactoryFfi;
      final path = '${await factory.getDatabasesPath()}/migrate_test.db';
      await factory.deleteDatabase(path);
      final v1 = await SqfliteDatabaseService.open(
        name: 'migrate_test.db',
        version: 1,
        factory: factory,
        onCreate: (db, _) =>
            db.execute('CREATE TABLE t(id INTEGER PRIMARY KEY)'),
      );
      await v1.close();
      final v2 = await SqfliteDatabaseService.open(
        name: 'migrate_test.db',
        version: 2,
        factory: factory,
        onCreate: (db, _) async {},
        onUpgrade: (db, from, to) =>
            db.execute('ALTER TABLE t ADD COLUMN name TEXT'),
      );
      await v2.insert('t', {'name': 'ok'});
      expect((await v2.query('t')).single['name'], 'ok');
      await v2.close();
      await factory.deleteDatabase(path);
    });
  });
}
