import 'package:flutter/material.dart';

import '../atoms/app_badge.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';

/// Summary card for an order / appointment / ticket: code + status on top,
/// a free-form body, and a footer with date and total.
class AppOrderCard extends StatelessWidget {
  const AppOrderCard({
    super.key,
    required this.code,
    required this.statusLabel,
    this.statusTone = AppTone.neutral,
    this.date,
    this.total,
    this.totalLabel = 'Tổng tiền',
    this.itemSummary,
    this.leading,
    this.onTap,
    this.actions,
  });

  final String code;
  final String statusLabel;
  final AppTone statusTone;
  final String? date;
  final String? total;
  final String totalLabel;

  /// e.g. "3 sản phẩm".
  final String? itemSummary;
  final Widget? leading;
  final VoidCallback? onTap;

  /// Buttons shown at the bottom right (e.g. "Huỷ", "Mua lại").
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Card.outlined(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.md,
            children: [
              Row(
                children: [
                  if (leading != null) ...[leading!, AppSpacing.gapMd],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(code, style: theme.textTheme.titleSmall),
                        if (date != null) Text(date!, style: muted),
                      ],
                    ),
                  ),
                  AppStatusBadge(label: statusLabel, tone: statusTone),
                ],
              ),
              if (itemSummary != null || total != null) ...[
                const Divider(),
                Row(
                  children: [
                    if (itemSummary != null)
                      Expanded(child: Text(itemSummary!, style: muted))
                    else
                      const Spacer(),
                    if (total != null)
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: '$totalLabel: ', style: muted),
                            TextSpan(
                              text: total,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
              if (actions != null && actions!.isNotEmpty)
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: actions!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
