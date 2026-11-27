// class StorageModule extends DIModule {
//   @override
//   Future<void> register(AppConfig config) async {
//     final prefs = await SharedPreferencesStorageService.init();
//     getIt.registerSingleton<StorageService>(prefs);
//     getIt.registerSingleton<SecureStorage>(SecureStorageImpl());
//   }
// }
