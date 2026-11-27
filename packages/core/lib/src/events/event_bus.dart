// Cái mình viết ở trên — 20 dòng, không dependency

import 'dart:async';

import 'app_event.dart';

class EventBus {
  final _controller = StreamController<AppEvent>.broadcast();

  void publish(AppEvent event) => _controller.add(event);

  Stream<T> on<T extends AppEvent>() =>
      _controller.stream.where((e) => e is T).cast<T>();

  void dispose() => _controller.close();
}
