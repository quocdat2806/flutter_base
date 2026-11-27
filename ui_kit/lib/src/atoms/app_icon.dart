import 'package:flutter/material.dart';

enum AppIconSize {
  small(16),
  medium(20),
  large(24),
  extraLarge(40);

  const AppIconSize(this.value);
  final double value;
}

/// Icon on the Material 3 size scale (default 24dp).
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.size = AppIconSize.large,
    this.color,
    this.semanticLabel,
  });

  final IconData icon;
  final AppIconSize size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) =>
      Icon(icon, size: size.value, color: color, semanticLabel: semanticLabel);
}
