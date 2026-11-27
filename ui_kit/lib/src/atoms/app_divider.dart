import 'package:flutter/material.dart';

/// Material 3 divider. [inset] adds the standard 16dp start indent
/// used in lists.
class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.inset = false, this.space})
    : axis = Axis.horizontal;

  const AppDivider.vertical({super.key, this.space})
    : axis = Axis.vertical,
      inset = false;

  final Axis axis;
  final bool inset;

  /// Total extent including padding around the line.
  final double? space;

  @override
  Widget build(BuildContext context) {
    if (axis == Axis.vertical) return VerticalDivider(width: space);
    return Divider(height: space, indent: inset ? 16 : 0);
  }
}
