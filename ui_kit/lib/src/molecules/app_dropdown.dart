import 'package:flutter/material.dart';

class AppDropdownItem<T> {
  const AppDropdownItem({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Outlined dropdown field that works inside a [Form] (supports validator).
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.label,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.validator,
    this.enabled = true,
  });

  final List<AppDropdownItem<T>> items;
  final ValueChanged<T?> onChanged;
  final T? value;
  final String? label;
  final String? hint;
  final String? helperText;
  final IconData? prefixIcon;
  final FormFieldValidator<T>? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      // Key on value so external changes to [value] are reflected.
      key: ValueKey(value),
      initialValue: value,
      isExpanded: true,
      validator: validator,
      onChanged: enabled ? onChanged : null,
      borderRadius: BorderRadius.circular(4),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      ),
      items: [
        for (final item in items)
          DropdownMenuItem<T>(
            value: item.value,
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Icon(item.icon, size: 20),
                  const SizedBox(width: 12),
                ],
                Flexible(
                  child: Text(item.label, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
