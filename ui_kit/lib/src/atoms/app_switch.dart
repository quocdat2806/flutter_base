import 'package:flutter/material.dart';

/// Material 3 switch with an optional label (label first, switch trailing).
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.subtitle,
    this.showIcon = false,
  });

  final bool value;

  /// `null` disables the switch.
  final ValueChanged<bool>? onChanged;
  final String? label;
  final String? subtitle;

  /// Shows a check icon in the thumb when on (Material 3 option).
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final thumbIcon = showIcon
        ? WidgetStateProperty<Icon?>.fromMap({
            WidgetState.selected: const Icon(Icons.check),
            WidgetState.any: null,
          })
        : null;

    if (label == null) {
      return Switch(value: value, onChanged: onChanged, thumbIcon: thumbIcon);
    }
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      thumbIcon: thumbIcon,
      title: Text(label!),
      subtitle: subtitle == null ? null : Text(subtitle!),
    );
  }
}
