import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import 'app_theme.dart';

ThemeData buildDarkTheme({
  Color seedColor = AppColors.seed,
  String? fontFamily,
}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  );
  return AppTheme.build(scheme, fontFamily: fontFamily);
}
