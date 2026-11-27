import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';

/// Material 3 notification badge placed on top of [child].
/// Shows a small dot when [count] is null, otherwise the number (99+ capped).
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.child,
    this.count,
    this.show = true,
    this.max = 99,
  });

  final Widget child;
  final int? count;
  final bool show;
  final int max;

  @override
  Widget build(BuildContext context) {
    final visible = show && (count == null || count! > 0);
    if (count == null) return Badge(isLabelVisible: visible, child: child);
    return Badge(
      isLabelVisible: visible,
      label: Text(count! > max ? '$max+' : '$count'),
      child: child,
    );
  }
}

/// Small tonal label used for statuses, e.g. "Đã giao", "Đang xử lý".
class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.label,
    this.tone = AppTone.neutral,
    this.icon,
  });

  final String label;
  final AppTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = AppToneColors.container(context, tone);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: AppRadius.smAll,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: c.foreground),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: context.textTheme.labelMedium?.copyWith(
                color: c.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
