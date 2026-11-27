import 'package:analytics/analytics.dart';
import 'package:flutter_test/flutter_test.dart';

class _Throwing implements AnalyticsProvider {
  @override
  String get name => 'throwing';
  @override
  Future<void> logEvent(AnalyticsEvent event) async => throw Exception('x');
  @override
  Future<void> logScreenView(String s, {String? screenClass}) async {}
  @override
  Future<void> reset() async {}
  @override
  Future<void> setUserId(String? userId) async {}
  @override
  Future<void> setUserProperty(String name, String? value) async {}
}

void main() {
  test('fans out and isolates provider failures', () async {
    final rec = RecordingAnalyticsProvider();
    final service = AnalyticsService(providers: [_Throwing(), rec]);
    await service.logEvent(AnalyticsEvent.login(method: 'otp'));
    expect(rec.events.single.name, 'login');
    expect(rec.events.single.params, {'method': 'otp'});
  });

  test('disabled service drops events and resets identity', () async {
    final rec = RecordingAnalyticsProvider();
    final service = AnalyticsService(providers: [rec]);
    await service.setUserId('u1');
    await service.setEnabled(enabled: false);
    await service.track('tap_book');
    expect(rec.events, isEmpty);
    expect(rec.userId, isNull);
  });

  test('asserts on invalid names', () {
    final service = AnalyticsService();
    expect(() => service.track('bad name'), throwsA(isA<AssertionError>()));
    expect(() => service.track('firebase_x'), throwsA(isA<AssertionError>()));
  });
}
