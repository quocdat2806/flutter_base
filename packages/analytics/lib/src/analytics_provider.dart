import 'analytics_event.dart';

/// Adapter for one analytics backend (Firebase, Mixpanel, AppsFlyer…).
///
/// Implement this in the app (or a dedicated plugin package) where the
/// vendor SDK is available; this package stays vendor-free.
abstract interface class AnalyticsProvider {
  /// Short id used in logs, e.g. `firebase`.
  String get name;

  Future<void> logEvent(AnalyticsEvent event);
  Future<void> logScreenView(String screenName, {String? screenClass});
  Future<void> setUserId(String? userId);
  Future<void> setUserProperty(String name, String? value);

  /// Clears user identity on logout.
  Future<void> reset();
}
