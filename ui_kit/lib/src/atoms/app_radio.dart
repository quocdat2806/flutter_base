import 'package:flutter/material.dart';

class AppRadioOption<T> {
  const AppRadioOption({
    required this.value,
    required this.label,
    this.enabled = true,
  });

  final T value;
  final String label;
  final bool enabled;
}

/// A vertical (or horizontal) group of labelled radio buttons.
class AppRadioGroup<T> extends StatelessWidget {
  const AppRadioGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.direction = Axis.vertical,
  });

  final List<AppRadioOption<T>> options;
  final T? value;
  final ValueChanged<T?> onChanged;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final items = [
      for (final o in options)
        MergeSemantics(
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: o.enabled ? () => onChanged(o.value) : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<T>(value: o.value, enabled: o.enabled),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    o.label,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
    ];
    return RadioGroup<T>(
      groupValue: value,
      onChanged: onChanged,
      child: direction == Axis.vertical
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items,
            )
          : Wrap(children: items),
    );
  }
}
