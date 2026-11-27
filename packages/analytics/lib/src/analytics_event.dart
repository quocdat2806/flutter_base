/// Allowed parameter value types (matches Firebase / most vendors).
typedef AnalyticsParams = Map<String, Object>;

/// A tracked event. Prefer the named factories so event names stay
/// consistent across apps; use the default constructor for feature-specific
/// events.
final class AnalyticsEvent {
  const AnalyticsEvent(this.name, [this.params = const {}]);

  // ---- Standard events (GA4 recommended names where they exist) ----------

  factory AnalyticsEvent.login({required String method}) =>
      AnalyticsEvent('login', {'method': method});

  factory AnalyticsEvent.signUp({required String method}) =>
      AnalyticsEvent('sign_up', {'method': method});

  factory AnalyticsEvent.logout() => const AnalyticsEvent('logout');

  factory AnalyticsEvent.search(String term) =>
      AnalyticsEvent('search', {'search_term': term});

  factory AnalyticsEvent.selectContent({
    required String contentType,
    required String itemId,
  }) => AnalyticsEvent('select_content', {
    'content_type': contentType,
    'item_id': itemId,
  });

  factory AnalyticsEvent.share({
    required String contentType,
    required String itemId,
    String? method,
  }) => AnalyticsEvent('share', {
    'content_type': contentType,
    'item_id': itemId,
    'method': ?method,
  });

  factory AnalyticsEvent.error({required String code, String? screen}) =>
      AnalyticsEvent('app_error', {'error_code': code, 'screen': ?screen});

  final String name;
  final AnalyticsParams params;

  @override
  String toString() => 'AnalyticsEvent($name, $params)';
}
