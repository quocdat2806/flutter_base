import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:widgetbook/widgetbook.dart';

import 'helpers.dart';

Widget _box(BuildContext context, String label) => AppCard.filled(
  child: SizedBox(width: double.infinity, child: Text(label)),
);

/// Staggered list; the replay button rebuilds with a fresh key.
Widget _demo(BuildContext context, Widget Function(int i, Widget child) wrap) {
  final stagger = context.knobs.int.slider(
    label: 'Stagger (ms)',
    initialValue: 80,
    min: 0,
    max: 300,
  );
  return Stateful<int>(
    initial: 0,
    builder: (context, run, set) => Showcase(
      children: [
        AppButton.tonal(
          label: 'Replay',
          icon: Icons.replay,
          onPressed: () => set(run + 1),
        ),
        KeyedSubtree(
          key: ValueKey(run),
          child: Column(
            spacing: 12,
            children: [
              for (var i = 0; i < 5; i++)
                wrap(i * stagger, _box(context, 'Item ${i + 1}')),
            ],
          ),
        ),
      ],
    ),
  );
}

final animationsFolder = WidgetbookFolder(
  name: 'Animations',
  children: [
    component('FadeInAnimation', {
      'Staggered': (context) => _demo(
        context,
        (ms, child) => FadeInAnimation(
          delay: Duration(milliseconds: ms),
          child: child,
        ),
      ),
    }),
    component('SlideInAnimation', {
      'Staggered': (context) => _demo(
        context,
        (ms, child) => SlideInAnimation(
          delay: Duration(milliseconds: ms),
          child: child,
        ),
      ),
    }),
    component('ScaleInAnimation', {
      'Staggered': (context) => _demo(
        context,
        (ms, child) => ScaleInAnimation(
          delay: Duration(milliseconds: ms),
          child: child,
        ),
      ),
    }),
  ],
);
