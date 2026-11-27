import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit_widgetbook/main.dart';
import 'package:widgetbook/widgetbook.dart';

Iterable<WidgetbookUseCase> _useCases(Iterable<WidgetbookNode> nodes) sync* {
  for (final node in nodes) {
    if (node is WidgetbookUseCase) yield node;
    yield* _useCases(node.children ?? const []);
  }
}

void main() {
  final useCases = _useCases(directories).toList();

  test('catalog is not empty', () => expect(useCases.length, greaterThan(30)));

  for (final useCase in useCases) {
    testWidgets('renders ${useCase.path}', (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(WidgetbookApp(
        initialRoute: '/?path=${Uri.encodeComponent(useCase.path)}',
      ));
      // Spinners never settle, so pump a fixed time past entrance animations.
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
    });
  }
}
