import 'package:flutter/material.dart';

/// Material 3 type scale. Colors are applied by the theme, so styles here
/// only define size, line height, weight and letter spacing.
abstract final class AppTypography {
  static TextTheme textTheme({String? fontFamily}) {
    TextStyle s(
      double size,
      double height,
      FontWeight weight,
      double spacing,
    ) => TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      height: height / size,
      fontWeight: weight,
      letterSpacing: spacing,
    );
    const regular = FontWeight.w400;
    const medium = FontWeight.w500;
    return TextTheme(
      displayLarge: s(57, 64, regular, -0.25),
      displayMedium: s(45, 52, regular, 0),
      displaySmall: s(36, 44, regular, 0),
      headlineLarge: s(32, 40, regular, 0),
      headlineMedium: s(28, 36, regular, 0),
      headlineSmall: s(24, 32, regular, 0),
      titleLarge: s(22, 28, regular, 0),
      titleMedium: s(16, 24, medium, 0.15),
      titleSmall: s(14, 20, medium, 0.1),
      labelLarge: s(14, 20, medium, 0.1),
      labelMedium: s(12, 16, medium, 0.5),
      labelSmall: s(11, 16, medium, 0.5),
      bodyLarge: s(16, 24, regular, 0.5),
      bodyMedium: s(14, 20, regular, 0.25),
      bodySmall: s(12, 16, regular, 0.4),
    );
  }
}
