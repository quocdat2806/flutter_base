import 'package:core/core.dart';

abstract class DIModule {
  Future<void> register(AppConfig config);
}
