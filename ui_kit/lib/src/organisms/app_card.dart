import 'package:flutter/material.dart';

import '../tokens/app_spacing.dart';

/// Material 3 card types.
enum AppCardVariant { elevated, filled, outlined }

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.padding = AppSpacing.card,
    this.onTap,
    this.onLongPress,
  });

  const AppCard.filled({
    super.key,
    required this.child,
    this.padding = AppSpacing.card,
    this.onTap,
    this.onLongPress,
  }) : variant = AppCardVariant.filled;

  const AppCard.outlined({
    super.key,
    required this.child,
    this.padding = AppSpacing.card,
    this.onTap,
    this.onLongPress,
  }) : variant = AppCardVariant.outlined;

  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(padding: padding, child: child);
    if (onTap != null || onLongPress != null) {
      content = InkWell(onTap: onTap, onLongPress: onLongPress, child: content);
    }
    return switch (variant) {
      AppCardVariant.elevated => Card(child: content),
      AppCardVariant.filled => Card.filled(child: content),
      AppCardVariant.outlined => Card.outlined(child: content),
    };
  }
}
