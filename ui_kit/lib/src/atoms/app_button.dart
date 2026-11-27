import 'package:flutter/material.dart';

/// Material 3 button variants, in order of emphasis.
enum AppButtonVariant { filled, tonal, elevated, outlined, text }

enum AppButtonSize { small, medium, large }

/// Single button API over Material 3's Filled/Tonal/Elevated/Outlined/Text
/// buttons with loading state, optional leading icon and full-width option.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.expanded = false,
  });

  const AppButton.tonal({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.expanded = false,
  }) : variant = AppButtonVariant.tonal;

  const AppButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.expanded = false,
  }) : variant = AppButtonVariant.outlined;

  const AppButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.expanded = false,
  }) : variant = AppButtonVariant.text;

  final String label;

  /// `null` disables the button.
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;

  /// Shows a spinner and blocks taps while keeping the button's size.
  final bool isLoading;

  /// Stretches to the parent's full width.
  final bool expanded;

  double get _height => switch (size) {
    AppButtonSize.small => 32,
    AppButtonSize.medium => 40,
    AppButtonSize.large => 56,
  };

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size(expanded ? double.infinity : 64, _height),
      ),
      padding: size == AppButtonSize.small
          ? const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16))
          : null,
    );
    final callback = isLoading ? null : onPressed;
    final child = isLoading ? _spinner(context) : Text(label);
    final iconWidget = icon == null || isLoading ? null : Icon(icon, size: 18);

    return switch (variant) {
      AppButtonVariant.filled =>
        iconWidget == null
            ? FilledButton(onPressed: callback, style: style, child: child)
            : FilledButton.icon(
                onPressed: callback,
                style: style,
                icon: iconWidget,
                label: child,
              ),
      AppButtonVariant.tonal =>
        iconWidget == null
            ? FilledButton.tonal(
                onPressed: callback,
                style: style,
                child: child,
              )
            : FilledButton.tonalIcon(
                onPressed: callback,
                style: style,
                icon: iconWidget,
                label: child,
              ),
      AppButtonVariant.elevated =>
        iconWidget == null
            ? ElevatedButton(onPressed: callback, style: style, child: child)
            : ElevatedButton.icon(
                onPressed: callback,
                style: style,
                icon: iconWidget,
                label: child,
              ),
      AppButtonVariant.outlined =>
        iconWidget == null
            ? OutlinedButton(onPressed: callback, style: style, child: child)
            : OutlinedButton.icon(
                onPressed: callback,
                style: style,
                icon: iconWidget,
                label: child,
              ),
      AppButtonVariant.text =>
        iconWidget == null
            ? TextButton(onPressed: callback, style: style, child: child)
            : TextButton.icon(
                onPressed: callback,
                style: style,
                icon: iconWidget,
                label: child,
              ),
    };
  }

  Widget _spinner(BuildContext context) {
    final color = switch (variant) {
      AppButtonVariant.filled => Theme.of(context).colorScheme.onPrimary,
      _ => Theme.of(context).colorScheme.primary,
    };
    return SizedBox.square(
      dimension: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: onPressed == null ? null : color,
      ),
    );
  }
}

/// Material 3 icon button variants.
enum AppIconButtonVariant { standard, filled, tonal, outlined }

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.variant = AppIconButtonVariant.standard,
    this.tooltip,
    this.selected,
    this.selectedIcon,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final AppIconButtonVariant variant;

  /// Also used as the accessibility label.
  final String? tooltip;

  /// Non-null makes this a toggle button.
  final bool? selected;
  final IconData? selectedIcon;

  @override
  Widget build(BuildContext context) {
    final i = Icon(icon);
    final si = selectedIcon == null ? null : Icon(selectedIcon);
    return switch (variant) {
      AppIconButtonVariant.standard => IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        isSelected: selected,
        selectedIcon: si,
        icon: i,
      ),
      AppIconButtonVariant.filled => IconButton.filled(
        onPressed: onPressed,
        tooltip: tooltip,
        isSelected: selected,
        selectedIcon: si,
        icon: i,
      ),
      AppIconButtonVariant.tonal => IconButton.filledTonal(
        onPressed: onPressed,
        tooltip: tooltip,
        isSelected: selected,
        selectedIcon: si,
        icon: i,
      ),
      AppIconButtonVariant.outlined => IconButton.outlined(
        onPressed: onPressed,
        tooltip: tooltip,
        isSelected: selected,
        selectedIcon: si,
        icon: i,
      ),
    };
  }
}
