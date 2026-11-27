// import 'dart:async';

// import 'package:api_client/api_client.dart';
// import 'package:auth/auth.dart';
// import 'package:core/core.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:provider/single_child_widget.dart';
// import 'package:storage/storage.dart';

// import '../blocs/auth/auth_bloc.dart';
// import '../blocs/theme/theme_mode_cubit.dart';
// import 'app_bloc_observer.dart';
// import 'app_dependencies.dart';

// /// Startup sequence shared by every app. Each app extends this and only
// /// declares what is specific to it:
// ///
// /// ```dart
// /// final class PatientBootstrap extends AppBootstrap {
// ///   @override
// ///   String get namespace => 'patient';
// ///
// ///   @override
// ///   Widget buildApp(AppDependencies deps) => const PatientApp();
// ///
// ///   @override
// ///   List<SingleChildWidget> extraProviders(AppDependencies deps) => [
// ///     RepositoryProvider<UserRepository>(
// ///       create: (_) => UserRepositoryImpl(client: deps.apiClient, ...),
// ///     ),
// ///   ];
// /// }
// ///
// /// void main() => PatientBootstrap().run(AppConfig.fromEnvironment());
// /// ```
// ///
// /// Provided to the tree: [AppConfig], [AppLogger], [StorageService] (prefs),
// /// [SecureStorage], [ApiClient], [AuthManager], plus [AuthBloc] and
// /// [ThemeModeCubit].
// abstract class AppBootstrap {
//   /// Prefix for every storage key of this app, e.g. `'patient'`.
//   String get namespace;

//   /// Root widget of the app (usually a `MaterialApp.router`).
//   Widget buildApp(AppDependencies deps);

//   /// App-specific repositories / blocs, placed below the shared providers so
//   /// they can read them.
//   List<SingleChildWidget> extraProviders(AppDependencies deps) => const [];

//   /// App-specific async setup (Firebase, analytics, remote config…), run
//   /// after the shared services exist and before the first frame.
//   Future<void> onInit(AppDependencies deps) async {}

//   /// Logger for this run. Override to plug in a crash-reporting adapter.
//   AppLogger createLogger(AppConfig config) =>
//       config.isProd ? const NoopLogger() : const ConsoleLogger();

//   /// Called for every uncaught error (framework, platform, zone) after it
//   /// has been logged. Override to forward to crash reporting.
//   void onUncaughtError(Object error, StackTrace stackTrace) {}

//   /// Auth endpoint paths, when the backend differs from the defaults.
//   AuthEndpoints get authEndpoints => const AuthEndpoints();

//   /// Headers sent with every request (e.g. app id / platform).
//   Map<String, String> get defaultHeaders => const {};

//   Future<void> run(AppConfig config) async {
//     final logger = createLogger(config);

//     void report(Object error, StackTrace stackTrace) {
//       logger.e(
//         'Uncaught error',
//         tag: 'app',
//         error: error,
//         stackTrace: stackTrace,
//       );
//       onUncaughtError(error, stackTrace);
//     }

//     await runZonedGuarded(() async {
//       WidgetsFlutterBinding.ensureInitialized();

//       FlutterError.onError = (details) {
//         FlutterError.presentError(details);
//         report(details.exception, details.stack ?? StackTrace.current);
//       };
//       PlatformDispatcher.instance.onError = (error, stackTrace) {
//         report(error, stackTrace);
//         return true;
//       };

//       final deps = await AppDependencies.create(
//         config: config,
//         namespace: namespace,
//         logger: logger,
//         authEndpoints: authEndpoints,
//         defaultHeaders: defaultHeaders,
//       );
//       if (!config.isProd) Bloc.observer = AppBlocObserver(logger);

//       await onInit(deps);

//       // Resolve the session and saved theme before the first frame so the
//       // router starts on the right screen with the right theme.
//       await deps.auth.restoreSession();
//       final themeModeCubit = ThemeModeCubit(deps.prefs);
//       await themeModeCubit.load();

//       runApp(
//         MultiRepositoryProvider(
//           providers: [
//             RepositoryProvider<AppConfig>.value(value: deps.config),
//             RepositoryProvider<AppLogger>.value(value: deps.logger),
//             RepositoryProvider<StorageService>.value(value: deps.prefs),
//             RepositoryProvider<SecureStorage>.value(value: deps.secureStorage),
//             RepositoryProvider<ApiClient>.value(value: deps.apiClient),
//             RepositoryProvider<AuthManager>.value(value: deps.auth),
//           ],
//           child: MultiBlocProvider(
//             providers: [
//               BlocProvider<AuthBloc>(create: (_) => AuthBloc(deps.auth)),
//               BlocProvider<ThemeModeCubit>.value(value: themeModeCubit),
//               ...extraProviders(deps),
//             ],
//             child: buildApp(deps),
//           ),
//         ),
//       );
//     }, report);
//   }
// }

// packages/app_core/lib/src/bootstrap/app_bootstrap.dart

// abstract class AppBootstrap {
//   /// Mỗi app override — DI riêng.
//   List<DIModule> get appModules => [];

//   /// Mỗi app override — setup riêng (Firebase, Printer...).
//   Future<void> onInit(AppConfig config) async {}

//   /// Widget gốc.
//   Widget get app;

//   Future<void> run(AppConfig config) async {
//     await runZonedGuarded(
//       () async {
//         WidgetsFlutterBinding.ensureInitialized();

//         // Logger
//         AppLogger.init(enabled: config.isDev);

//         // Error messages
//         ErrorMessages.setLocale('vi');

//         // BLoC observer
//         if (config.isDev) {
//           Bloc.observer = AppBlocObserver();
//         }

//         // DI — shared + app-specific
//         await Injection.init(config, appModules: appModules);

//         // App-specific init (Firebase, Printer...)
//         await onInit(config);

//         // Error handling
//         FlutterError.onError = onFlutterError;
//         PlatformDispatcher.instance.onError = (error, stack) {
//           onPlatformError(error, stack);
//           return true;
//         };

//         runApp(app);
//       },
//       onUncaughtError,
//     );
//   }

//   void onFlutterError(FlutterErrorDetails details) {
//     log.e('Flutter error', error: details.exception, stackTrace: details.stack);
//   }

//   void onPlatformError(Object error, StackTrace stack) {
//     log.e('Platform error', error: error, stackTrace: stack);
//   }

//   void onUncaughtError(Object error, StackTrace stack) {
//     log.e('Uncaught error', error: error, stackTrace: stack);
//   }
// }
