/// Local persistence, one library per purpose:
///
/// | Purpose               | Interface         | Implementation                     |
/// |-----------------------|-------------------|------------------------------------|
/// | Key-value settings    | [StorageService]  | [SharedPreferencesStorageService]  |
/// | Secrets (tokens, PII) | [StorageService]  | [SecureStorageService]             |
/// | Relational local DB   | [DatabaseService] | [SqfliteDatabaseService]           |
///
/// Depend on the interfaces; pick implementations at the composition root.
/// In tests, use the real implementations with the plugins' mocks
/// (`InMemorySharedPreferencesAsync`, `FlutterSecureStorage.setMockInitialValues`).
library;

// The key-value contract lives in core so pure-Dart code can depend on it.
export 'package:core/core.dart'
    show StorageService, SecureStorage, StorageServiceJson, CacheFailure,
        UniqueConstraintFailure, CacheStore, CacheRecord;

export 'src/app_database.dart';
export 'src/database_service.dart';
export 'src/memory_cache_store.dart';
export 'src/secure_storage_service.dart';
export 'src/shared_preferences_storage_service.dart';
export 'src/sqflite_cache_store.dart';
export 'src/sqflite_database_service.dart';
