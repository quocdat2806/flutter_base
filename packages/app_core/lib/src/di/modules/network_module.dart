// class NetworkModule extends DIModule {
//   @override
//   Future<void> register(AppConfig config) async {
//     getIt.registerSingleton<ApiClient>(
//       ApiClient(
//         baseUrl: config.apiBaseUrl,
//         secureStorage: getIt<SecureStorage>(),
//         enableLogging: config.enableNetworkLogs,
//       ),
//     );
//   }
// }
