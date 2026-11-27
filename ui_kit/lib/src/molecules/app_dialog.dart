import 'package:flutter/material.dart';

/// Material 3 basic dialogs.
abstract final class AppDialog {
  /// Shows a confirm dialog. Returns `true` on confirm, `false` on cancel,
  /// `null` if dismissed.
  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    String? message,
    IconData? icon,
    String confirmLabel = 'Xác nhận',
    String cancelLabel = 'Huỷ',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        final c = Theme.of(context).colorScheme;
        return AlertDialog(
          icon: icon == null ? null : Icon(icon),
          title: Text(title),
          content: message == null ? null : Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelLabel),
            ),
            TextButton(
              style: isDestructive
                  ? TextButton.styleFrom(foregroundColor: c.error)
                  : null,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
  }

  /// Shows an informational dialog with a single button.
  static Future<void> alert(
    BuildContext context, {
    required String title,
    String? message,
    IconData? icon,
    String buttonLabel = 'Đóng',
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: icon == null ? null : Icon(icon),
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }

  /// Shows a dialog with custom content.
  static Future<T?> custom<T>(
    BuildContext context, {
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) =>
          AlertDialog(title: Text(title), content: content, actions: actions),
    );
  }
}
