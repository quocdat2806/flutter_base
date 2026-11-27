import 'package:flutter/material.dart';

/// Checkbox with an optional tappable label. Set [tristate] to allow `null`.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.tristate = false,
    this.isError = false,
  });

  final bool? value;

  /// `null` disables the checkbox.
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final bool tristate;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final box = Checkbox(
      value: value,
      tristate: tristate,
      isError: isError,
      onChanged: onChanged,
    );
    if (label == null) return box;

    return MergeSemantics(
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onChanged == null ? null : () => onChanged!(_next()),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            box,
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  label!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool? _next() {
    if (!tristate) return !(value ?? false);
    return switch (value) {
      false => true,
      true => null,
      null => false,
    };
  }
}
