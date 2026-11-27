import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:widgetbook/widgetbook.dart';

import 'use_cases/animations.dart';
import 'use_cases/atoms.dart';
import 'use_cases/molecules.dart';
import 'use_cases/organisms.dart';
import 'use_cases/tokens.dart';

void main() => runApp(const WidgetbookApp());

/// All ui_kit directories, grouped like the source tree.
final List<WidgetbookNode> directories = [
  tokensFolder,
  atomsFolder,
  moleculesFolder,
  organismsFolder,
  animationsFolder,
];

class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key, this.initialRoute = '/'});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      initialRoute: initialRoute,
      directories: directories,
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Light', data: AppTheme.light()),
            WidgetbookTheme(name: 'Dark', data: AppTheme.dark()),
          ],
        ),
        ViewportAddon([
          Viewports.none,
          IosViewports.iPhone13,
          IosViewports.iPhoneSE,
          AndroidViewports.samsungGalaxyS20,
          IosViewports.iPadAir4,
        ]),
        TextScaleAddon(min: 1.0, max: 2.0),
        AlignmentAddon(),
        ZoomAddon(),
        InspectorAddon(),
        GridAddon(8),
      ],
    );
  }
}
