// packages/core/lib/src/logger.dart
import 'package:logger/logger.dart';

final log = AppLogger();

class AppLogger {
  late final Logger _logger;

  static bool _enabled = true;

  AppLogger() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }

  static void init({bool enabled = true}) {
    _enabled = enabled;
    if (!enabled) {
      Logger.level = Level.off;
    }
  }

  void d(String message) => _enabled ? _logger.d(message) : null;
  void i(String message) => _enabled ? _logger.i(message) : null;
  void w(String message) => _enabled ? _logger.w(message) : null;
  void e(String message, {Object? error, StackTrace? stackTrace}) => _enabled
      ? _logger.e(message, error: error, stackTrace: stackTrace)
      : null;
}
