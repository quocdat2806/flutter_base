# Company Monorepo

```
apps/       Flutter apps: customer_support (vn.vietlife.app.customer.support), patient (vn.vietlife.app.patient)
packages/   Shared code: core (pure Dart), api_client, auth, analytics, storage, utils, repositories, app_core (Flutter + flutter_bloc: bootstrap, shared blocs)
ui_kit/     Design system: atoms / molecules / organisms / tokens / theme (+ widgetbook/ catalog app)
plugins/    Flutter plugins bridging native code
```

Uses Dart pub workspaces + melos (config lives in the root `pubspec.yaml`).

## Setup

```bash
dart pub global activate melos
melos bootstrap
```

Generate native platform folders (first time only):

```bash
cd apps/customer_app && flutter create --platforms=android,ios .
cd plugins/native_scanner && flutter create --template=plugin --platforms=android,ios .
```

## Scripts

`melos run analyze` · `melos run format` · `melos run test` · `melos run clean`

## Widgetbook (ui_kit catalog)

`ui_kit/widgetbook` catalogs every `ui_kit` component with knobs, light/dark themes and device viewports.

```bash
cd ui_kit/widgetbook && flutter run -d chrome   # or -d macos
```

Use cases are declared by hand in `ui_kit/widgetbook/lib/use_cases/` (one folder per atomic level).
`widgetbook_generator` is not used because it requires `build` < 5, which conflicts with the workspace `build_runner`.
When adding a component to `ui_kit`, add a use case there too — `flutter test` in `ui_kit/widgetbook` renders every use case and fails on layout errors.

## Packages

```
                 ┌────────────┐
                 │    core    │  Result, AppException, AppConfig, AppLogger, Paginated
                 └─────▲──────┘
     ┌──────────┬──────┴─────┬─────────────┐
 ┌───┴───┐ ┌────┴────┐ ┌─────┴─────┐ ┌─────┴─────┐
 │ utils │ │ storage │ │ api_client│ │ analytics │
 └───────┘ └──▲───▲──┘ └──▲─────▲──┘ └───────────┘
              │   └───┐ ┌─┘     │
              │     ┌─┴─┴┐      │
              │     │auth│      │
              │     └────┘      │
            ┌─┴─────────────────┴─┐
            │    repositories     │
            └─────────────────────┘
```

| Package | Responsibility | Key API |
|---|---|---|
| `core` | Foundation, no deps | `Result`/`Success`/`Failure`, sealed `AppException`, `UseCase`, `AppConfig`/`Flavor`, `AppLogger`, `Paginated` |
| `utils` | Pure helpers | `StringX` (bỏ dấu, initials, mask), `Validators`, `PhoneFormatter` (VN), `CurrencyFormatter.vnd`, `DateFormatter`, `Debouncer`/`Throttler`/`retry` |
| `storage` | One library per purpose | Key-value: `StorageService` → `SharedPreferencesStorageService`; secrets: `SecureStorage` → `SecureStorageService` (Keychain/Keystore); local DB: `DatabaseService` → `SqfliteDatabaseService` (throws `UniqueConstraintFailure` on duplicates; `deleteDatabase` for sign-out) |
| `api_client` | HTTP | `ApiClient` (get/post/…/upload/download, `guard` for Retrofit), `Decoders`, `AuthInterceptor` + `AuthTokenProvider`, `RetryInterceptor`, `LoggingInterceptor` (redacts secrets), `ApiErrorMapper` |
| `auth` | Session | `AuthManager` (restore, login password/OTP, single-flight refresh, logout, `status` stream), `RestAuthApi`, `SecureTokenStorage` |
| `analytics` | Tracking facade | `AnalyticsService`, `AnalyticsProvider` (implement Firebase/Mixpanel in app), `AnalyticsEvent` |
| `app_core` | Flutter-side foundation (depends on core, api_client, storage, auth) | `AppBootstrap`, `AppDependencies`, `AppBlocObserver`, `AuthBloc`, `ThemeModeCubit` |
| `repositories` | Data layer | `BaseRepository.guard`, `JsonCache` + `CachePolicy`, `UserRepository` (example feature) |

### Rules

* Every failure crossing a package boundary is an `AppException`; repositories return `Result<T>` and never throw.
* Depend on interfaces (`StorageService`, `AuthApi`, `UserRepository`, `AnalyticsProvider`); pick implementations only in the app's composition root.
* Endpoint paths and error body parsing are configurable (`AuthEndpoints`, `UserEndpoints`, `ApiErrorMapper(parseBody:)`); adjust to the real backend contract.

### Wiring (composition root)

Every app starts through `AppBootstrap` from `app_core`, which builds and wires the shared services (prefs, secure storage, `ApiClient`, `AuthManager`), installs global error handling, restores the session and provides everything to the widget tree together with `AuthBloc` and `ThemeModeCubit`. The app only adds what is specific to it:

```dart
final class PatientBootstrap extends AppBootstrap {
  @override
  String get namespace => 'patient'; // storage key prefix

  @override
  Widget buildApp(AppDependencies deps) => const PatientApp();

  @override
  List<SingleChildWidget> extraProviders(AppDependencies deps) => [
    RepositoryProvider<UserRepository>(
      create: (_) => UserRepositoryImpl(
        client: deps.apiClient,
        cache: JsonCache(deps.prefs),
        logger: deps.logger,
      ),
    ),
  ];

  @override
  Future<void> onInit(AppDependencies deps) async {
    // Firebase.initializeApp(), analytics providers, remote config…
  }
}

// --dart-define=FLAVOR=dev --dart-define=API_BASE_URL=...
void main() => PatientBootstrap().run(AppConfig.fromEnvironment());
```

In widgets: `context.read<ApiClient>()`, `context.watch<AuthBloc>().state.isAuthenticated`, `context.read<ThemeModeCubit>().setMode(ThemeMode.dark)`. Drive `go_router`'s redirect from `AuthBloc` (or `AuthManager.status`).

### Testing note

`storage`, `auth`, `repositories` and `app_core` transitively depend on plugins with native build hooks, so `flutter test` needs a working Xcode toolchain on macOS.

## Code generation

`core` uses Freezed + json_serializable (`Result`, `AppConfig`, `Paginated`) and `app_core` uses Freezed (`AuthEvent`, `AuthState`). Generated `*.freezed.dart` / `*.g.dart` files are checked in next to their source; regenerate after editing an annotated class:

```bash
cd packages/core && dart run build_runner build --delete-conflicting-outputs   # same in packages/app_core
```

## Dependency rule

`apps → app_core → auth / api_client / storage → core` · `apps → ui_kit` · `core` is pure Dart (no Flutter SDK or plugin in its runtime dependencies; `flutter_test` is dev-only) and imports no other workspace package · `packages` never import Flutter widgets (plugin-backed ones such as `storage` depend on the Flutter SDK, but ship no UI) · `ui_kit` never imports `packages/api_client`.
