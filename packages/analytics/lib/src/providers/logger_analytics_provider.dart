import 'package:core/core.dart';

import '../analytics_event.dart';
import '../analytics_provider.dart';

/// Prints every call – use in dev builds to verify tracking plans.
final class LoggerAnalyticsProvider implements AnalyticsProvider {
  const LoggerAnalyticsProvider(this._logger);

  final AppLogger _logger;

  @override
  String get name => 'logger';

  void _log(String msg) => _logger.d(msg, tag: 'analytics');

  @override
  Future<void> logEvent(AnalyticsEvent event) async =>
      _log('event ${event.name} ${event.params}');

  @override
  Future<void> logScreenView(String screenName, {String? screenClass}) async =>
      _log('screen $screenName');

  @override
  Future<void> setUserId(String? userId) async => _log('userId=$userId');

  @override
  Future<void> setUserProperty(String name, String? value) async =>
      _log('property $name=$value');

  @override
  Future<void> reset() async => _log('reset');
}

/// Records calls in memory – for unit tests asserting tracking.
final class RecordingAnalyticsProvider implements AnalyticsProvider {
  final List<AnalyticsEvent> events = [];
  final List<String> screens = [];
  final Map<String, String?> userProperties = {};
  String? userId;

  @override
  String get name => 'recording';

  @override
  Future<void> logEvent(AnalyticsEvent event) async => events.add(event);

  @override
  Future<void> logScreenView(String screenName, {String? screenClass}) async =>
      screens.add(screenName);

  @override
  Future<void> setUserId(String? userId) async => this.userId = userId;

  @override
  Future<void> setUserProperty(String name, String? value) async =>
      userProperties[name] = value;

  @override
  Future<void> reset() async {
    userId = null;
    userProperties.clear();
  }
}
