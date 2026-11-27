import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../tokens/app_colors.dart';

/// Floating Material 3 snackbar. [AppTone.neutral] uses the standard
/// inverse-surface style; other tones color the snackbar accordingly.
abstract final class AppSnackbar {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context,
    String message, {
    AppTone tone = AppTone.neutral,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
    bool showCloseIcon = false,
  }) {
    final colors = tone == AppTone.neutral
        ? null
        : AppToneColors.solid(context, tone);
    final icon = switch (tone) {
      AppTone.success => Icons.check_circle_outline,
      AppTone.warning => Icons.warning_amber_rounded,
      AppTone.error => Icons.error_outline,
      AppTone.info => Icons.info_outline,
      _ => null,
    };
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    return messenger.showSnackBar(
      SnackBar(
        backgroundColor: colors?.background,
        duration: duration,
        showCloseIcon: showCloseIcon,
        closeIconColor: colors?.foreground,
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: colors?.foreground, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: colors == null
                    ? null
                    : TextStyle(color: colors.foreground),
              ),
            ),
          ],
        ),
        action: actionLabel == null
            ? null
            : SnackBarAction(
                label: actionLabel,
                textColor: colors?.foreground,
                onPressed: onAction ?? () {},
              ),
      ),
    );
  }

  static void success(BuildContext context, String message) =>
      show(context, message, tone: AppTone.success);

  static void error(BuildContext context, String message) =>
      show(context, message, tone: AppTone.error);

  static void warning(BuildContext context, String message) =>
      show(context, message, tone: AppTone.warning);

  static void info(BuildContext context, String message) =>
      show(context, message, tone: AppTone.info);
}
