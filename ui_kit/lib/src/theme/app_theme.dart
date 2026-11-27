import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'dark_theme.dart';
import 'light_theme.dart';

/// Entry point for app themes.
///
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light(),
///   darkTheme: AppTheme.dark(),
/// )
/// ```
abstract final class AppTheme {
  static ThemeData light({
    Color seedColor = AppColors.seed,
    String? fontFamily,
  }) => buildLightTheme(seedColor: seedColor, fontFamily: fontFamily);

  static ThemeData dark({
    Color seedColor = AppColors.seed,
    String? fontFamily,
  }) => buildDarkTheme(seedColor: seedColor, fontFamily: fontFamily);

  /// Shared builder: applies Material 3 component defaults on top of [scheme].
  static ThemeData build(ColorScheme scheme, {String? fontFamily}) {
    final textTheme = AppTypography.textTheme(fontFamily: fontFamily)
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    const buttonShape = StadiumBorder();
    const buttonPadding = EdgeInsets.symmetric(horizontal: AppSpacing.xl);
    const buttonMinSize = Size(64, 40);

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: AppRadius.xsAll,
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: scheme.brightness,
      fontFamily: fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      visualDensity: VisualDensity.standard,
      extensions: [AppSemanticColors.fromBrightness(scheme.brightness)],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: scheme.surfaceTint,
        elevation: 0,
        scrolledUnderElevation: 3,
        titleTextStyle: textTheme.titleLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: buttonShape,
          padding: buttonPadding,
          minimumSize: buttonMinSize,
          textStyle: textTheme.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: buttonShape,
          padding: buttonPadding,
          minimumSize: buttonMinSize,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: buttonShape,
          padding: buttonPadding,
          minimumSize: buttonMinSize,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: buttonShape,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          minimumSize: buttonMinSize,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: border(scheme.outline),
        enabledBorder: border(scheme.outline),
        focusedBorder: border(scheme.primary, 2),
        errorBorder: border(scheme.error),
        focusedErrorBorder: border(scheme.error, 2),
        disabledBorder: border(scheme.onSurface.withValues(alpha: 0.12)),
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
      chipTheme: const ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
      ),
      dialogTheme: DialogThemeData(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
        backgroundColor: scheme.surfaceContainerHigh,
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.extraLarge),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        actionTextColor: scheme.inversePrimary,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xsAll),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.secondaryContainer,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        iconColor: scheme.onSurfaceVariant,
        titleTextStyle: textTheme.bodyLarge,
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
      ),
    );
  }
}

/// Shortcuts for reading theme values inside widgets.
extension AppThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  AppSemanticColors get semanticColors =>
      Theme.of(this).extension<AppSemanticColors>() ??
      AppSemanticColors.fromBrightness(Theme.of(this).brightness);
}

/// Resolved foreground/background pair for an [AppTone].
class AppToneColors {
  const AppToneColors(this.background, this.foreground);

  final Color background;
  final Color foreground;

  /// Container (tonal) colors, e.g. for badges and status chips.
  factory AppToneColors.container(BuildContext context, AppTone tone) {
    final c = context.colors;
    final s = context.semanticColors;
    return switch (tone) {
      AppTone.neutral => AppToneColors(
        c.surfaceContainerHighest,
        c.onSurfaceVariant,
      ),
      AppTone.primary => AppToneColors(
        c.primaryContainer,
        c.onPrimaryContainer,
      ),
      AppTone.success => AppToneColors(
        s.successContainer,
        s.onSuccessContainer,
      ),
      AppTone.warning => AppToneColors(
        s.warningContainer,
        s.onWarningContainer,
      ),
      AppTone.error => AppToneColors(c.errorContainer, c.onErrorContainer),
      AppTone.info => AppToneColors(s.infoContainer, s.onInfoContainer),
    };
  }

  /// Solid (high-emphasis) colors.
  factory AppToneColors.solid(BuildContext context, AppTone tone) {
    final c = context.colors;
    final s = context.semanticColors;
    return switch (tone) {
      AppTone.neutral => AppToneColors(c.inverseSurface, c.onInverseSurface),
      AppTone.primary => AppToneColors(c.primary, c.onPrimary),
      AppTone.success => AppToneColors(s.success, s.onSuccess),
      AppTone.warning => AppToneColors(s.warning, s.onWarning),
      AppTone.error => AppToneColors(c.error, c.onError),
      AppTone.info => AppToneColors(s.info, s.onInfo),
    };
  }
}
