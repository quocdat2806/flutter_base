import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:widgetbook/widgetbook.dart';

import 'helpers.dart';

final tokensFolder = WidgetbookFolder(
  name: 'Tokens',
  children: [
    component('Colors', {'Color scheme': (context) => const _ColorsPage()}),
    component('Typography', {
      'Type scale': (context) => const _TypographyPage(),
    }),
    component('Spacing & Radius', {'Scale': (context) => const _SpacingPage()}),
    component('Elevation', {'Shadows': (context) => const _ElevationPage()}),
  ],
);

class _ColorsPage extends StatelessWidget {
  const _ColorsPage();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = context.semanticColors;
    final groups = <String, List<(String, Color, Color)>>{
      'Primary': [
        ('primary', c.primary, c.onPrimary),
        ('primaryContainer', c.primaryContainer, c.onPrimaryContainer),
      ],
      'Secondary': [
        ('secondary', c.secondary, c.onSecondary),
        ('secondaryContainer', c.secondaryContainer, c.onSecondaryContainer),
      ],
      'Tertiary': [
        ('tertiary', c.tertiary, c.onTertiary),
        ('tertiaryContainer', c.tertiaryContainer, c.onTertiaryContainer),
      ],
      'Error': [
        ('error', c.error, c.onError),
        ('errorContainer', c.errorContainer, c.onErrorContainer),
      ],
      'Semantic': [
        ('success', s.success, s.onSuccess),
        ('successContainer', s.successContainer, s.onSuccessContainer),
        ('warning', s.warning, s.onWarning),
        ('warningContainer', s.warningContainer, s.onWarningContainer),
        ('info', s.info, s.onInfo),
        ('infoContainer', s.infoContainer, s.onInfoContainer),
      ],
      'Surface': [
        ('surface', c.surface, c.onSurface),
        ('surfaceContainerLow', c.surfaceContainerLow, c.onSurface),
        ('surfaceContainer', c.surfaceContainer, c.onSurface),
        ('surfaceContainerHigh', c.surfaceContainerHigh, c.onSurface),
        (
          'surfaceContainerHighest',
          c.surfaceContainerHighest,
          c.onSurfaceVariant,
        ),
        ('inverseSurface', c.inverseSurface, c.onInverseSurface),
        ('outline', c.outline, c.surface),
        ('outlineVariant', c.outlineVariant, c.onSurface),
      ],
    };
    return Showcase(
      children: [
        for (final g in groups.entries) ...[
          Text(g.key, style: context.textTheme.titleMedium),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (name, bg, fg) in g.value)
                Container(
                  width: 168,
                  height: 72,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: AppRadius.smAll,
                  ),
                  child: Text(
                    name,
                    style: context.textTheme.labelMedium?.copyWith(color: fg),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _TypographyPage extends StatelessWidget {
  const _TypographyPage();

  @override
  Widget build(BuildContext context) {
    final t = context.textTheme;
    final styles = {
      'displayLarge': t.displayLarge,
      'displayMedium': t.displayMedium,
      'displaySmall': t.displaySmall,
      'headlineLarge': t.headlineLarge,
      'headlineMedium': t.headlineMedium,
      'headlineSmall': t.headlineSmall,
      'titleLarge': t.titleLarge,
      'titleMedium': t.titleMedium,
      'titleSmall': t.titleSmall,
      'bodyLarge': t.bodyLarge,
      'bodyMedium': t.bodyMedium,
      'bodySmall': t.bodySmall,
      'labelLarge': t.labelLarge,
      'labelMedium': t.labelMedium,
      'labelSmall': t.labelSmall,
    };
    return Showcase(
      spacing: 8,
      children: [
        for (final e in styles.entries)
          Text(
            '${e.key} · ${e.value!.fontSize!.toInt()}sp — Chăm sóc sức khoẻ',
            style: e.value,
          ),
      ],
    );
  }
}

class _SpacingPage extends StatelessWidget {
  const _SpacingPage();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const spacing = {
      'xxs': AppSpacing.xxs,
      'xs': AppSpacing.xs,
      'sm': AppSpacing.sm,
      'md': AppSpacing.md,
      'lg': AppSpacing.lg,
      'xl': AppSpacing.xl,
      'xxl': AppSpacing.xxl,
      'xxxl': AppSpacing.xxxl,
    };
    const radius = {
      'extraSmall': AppRadius.extraSmall,
      'small': AppRadius.small,
      'medium': AppRadius.medium,
      'large': AppRadius.large,
      'extraLarge': AppRadius.extraLarge,
      'full': AppRadius.full,
    };
    return Showcase(
      children: [
        Text('Spacing (4dp grid)', style: context.textTheme.titleMedium),
        for (final e in spacing.entries)
          Row(
            children: [
              SizedBox(
                width: 120,
                child: Text('${e.key} · ${e.value.toInt()}'),
              ),
              Container(width: e.value, height: 16, color: c.primary),
            ],
          ),
        Text('Radius (M3 shape scale)', style: context.textTheme.titleMedium),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final e in radius.entries)
              Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: c.primaryContainer,
                      borderRadius: BorderRadius.circular(e.value),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(e.key, style: context.textTheme.labelSmall),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _ElevationPage extends StatelessWidget {
  const _ElevationPage();

  @override
  Widget build(BuildContext context) {
    const levels = [
      AppShadows.none,
      AppShadows.level1,
      AppShadows.level2,
      AppShadows.level3,
      AppShadows.level4,
      AppShadows.level5,
    ];
    return Showcase(
      children: [
        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            for (var i = 0; i < levels.length; i++)
              Container(
                width: 120,
                height: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerLow,
                  borderRadius: AppRadius.mdAll,
                  boxShadow: levels[i],
                ),
                child: Text('Level $i'),
              ),
          ],
        ),
      ],
    );
  }
}
