// // packages/app_core/lib/src/di/modules/repo_module.dart

// class RepoModule extends DIModule {
//   @override
//   Future<void> register(AppConfig config) async {
//     getIt.registerLazySingleton<AuthRepository>(
//       () => AuthRepositoryImpl(
//         apiClient: getIt<ApiClient>(),
//         secureStorage: getIt<SecureStorage>(),
//       ),
//     );

//     getIt.registerLazySingleton<UserRepository>(
//       () => UserRepositoryImpl(
//         apiClient: getIt<ApiClient>(),
//         storage: getIt<StorageService>(),
//       ),
//     );

//     getIt.registerLazySingleton<ProductRepository>(
//       () => ProductRepositoryImpl(
//         apiClient: getIt<ApiClient>(),
//       ),
//     );

//     getIt.registerLazySingleton<OrderRepository>(
//       () => OrderRepositoryImpl(
//         apiClient: getIt<ApiClient>(),
//       ),
//     );
//   }
// }
