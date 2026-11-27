import 'package:core/core.dart';

import 'analytics_event.dart';
import 'analytics_provider.dart';

/// Facade the app talks to. Fans out to every registered provider,
/// validates names, and isolates failures so analytics can never crash or
/// block a user flow.
final class AnalyticsService {
  AnalyticsService({
    List<AnalyticsProvider> providers = const [],
    bool enabled = true,
    AppLogger logger = const NoopLogger(),
    this.strictNames = true,
  }) : _providers = List.of(providers),
       _enabled = enabled,
       _logger = logger;

  final List<AnalyticsProvider> _providers;
  final AppLogger _logger;

  /// Throws in debug (assert) when an event / param name violates GA4 rules.
  final bool strictNames;
  bool _enabled;

  static const _tag = 'analytics';
  static final _validName = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]{0,39}$');
  static const _reservedPrefixes = ['firebase_', 'google_', 'ga_'];

  bool get isEnabled => _enabled;

  /// Toggle at runtime (e.g. user consent). Disabling also resets identity.
  Future<void> setEnabled({required bool enabled}) async {
    if (_enabled == enabled) return;
    if (!enabled) await reset();
    _enabled = enabled;
  }

  void addProvider(AnalyticsProvider provider) => _providers.add(provider);

  Future<void> logEvent(AnalyticsEvent event) {
    if (strictNames) {
      assert(
        _isValid(event.name),
        'Invalid analytics event name "${event.name}"',
      );
      assert(
        event.params.keys.every(_isValid),
        'Invalid param name in ${event.params.keys}',
      );
    }
    return _dispatch('logEvent(${event.name})', (p) => p.logEvent(event));
  }

  /// Shortcut for ad-hoc events.
  Future<void> track(String name, [AnalyticsParams params = const {}]) =>
      logEvent(AnalyticsEvent(name, params));

  Future<void> logScreenView(String screenName, {String? screenClass}) =>
      _dispatch(
        'screen($screenName)',
        (p) => p.logScreenView(screenName, screenClass: screenClass),
      );

  Future<void> setUserId(String? userId) =>
      _dispatch('setUserId', (p) => p.setUserId(userId));

  Future<void> setUserProperty(String name, String? value) => _dispatch(
    'setUserProperty($name)',
    (p) => p.setUserProperty(name, value),
  );

  Future<void> reset() => _dispatch('reset', (p) => p.reset());

  bool _isValid(String name) =>
      _validName.hasMatch(name) && !_reservedPrefixes.any(name.startsWith);

  Future<void> _dispatch(
    String label,
    Future<void> Function(AnalyticsProvider provider) call,
  ) async {
    if (!_enabled || _providers.isEmpty) return;
    await Future.wait(
      _providers.map((provider) async {
        try {
          await call(provider);
        } catch (e, st) {
          _logger.e(
            '${provider.name}.$label failed',
            tag: _tag,
            error: e,
            stackTrace: st,
          );
        }
      }),
    );
  }
}
