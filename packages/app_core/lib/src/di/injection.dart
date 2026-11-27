// // packages/app_core/lib/src/di/injection.dart

// class Injection {
//   Injection._();

//   static Future<void> init(
//     AppConfig config, {
//     List<DIModule> appModules = const [],
//   }) async {
//     // Config
//     getIt.registerSingleton<AppConfig>(config);

//     // Shared — thứ tự quan trọng
//     await StorageModule().register(config);
//     await NetworkModule().register(config);
//     await RepoModule().register(config);

//     // App-specific
//     for (final module in appModules) {
//       await module.register(config);
//     }
//   }

//   static Future<void> reset() => getIt.reset();
// }
