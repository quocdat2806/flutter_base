import 'package:sqflite/sqflite.dart' show DatabaseFactory;

import 'sqflite_cache_store.dart';
import 'sqflite_database_service.dart';

/// Opens the app's single local database (`app.db`).
///
/// Every table lives here; add a new table by bumping [appDatabaseVersion]
/// and adding a step to `onUpgrade`.
///
/// | Version | Change              |
/// |---------|---------------------|
/// | 1       | `cache` table       |
const appDatabaseVersion = 1;

Future<SqfliteDatabaseService> openAppDatabase({
  String name = 'app.db',
  DatabaseFactory? factory,
}) => SqfliteDatabaseService.open(
  name: name,
  version: appDatabaseVersion,
  factory: factory,
  onCreate: (db, version) => SqfliteCacheStore.createTable(db),
);
