/// Vendor-agnostic analytics. Apps register concrete [AnalyticsProvider]s
/// (Firebase, Mixpanel…) and call [AnalyticsService] only.
library;

export 'src/analytics_event.dart';
export 'src/analytics_provider.dart';
export 'src/analytics_service.dart';
export 'src/providers/logger_analytics_provider.dart';
