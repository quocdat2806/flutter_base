import 'package:flutter/material.dart';

import '../atoms/app_badge.dart';
import '../atoms/app_image.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';

/// Vertical product card for grids. Prices are passed pre-formatted
/// (formatting/currency is the app's responsibility).
class AppProductCard extends StatelessWidget {
  const AppProductCard({
    super.key,
    required this.name,
    required this.price,
    this.imageUrl,
    this.originalPrice,
    this.subtitle,
    this.tag,
    this.tagTone = AppTone.error,
    this.onTap,
    this.onAddToCart,
    this.imageAspectRatio = 1,
  });

  final String name;
  final String price;
  final String? imageUrl;

  /// Shown struck-through when non-null (e.g. before discount).
  final String? originalPrice;
  final String? subtitle;

  /// Small label over the image, e.g. "-20%".
  final String? tag;
  final AppTone tagTone;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final double imageAspectRatio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.colorScheme;
    return Card.outlined(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: imageAspectRatio,
                  child: AppImage(imageUrl, semanticLabel: name),
                ),
                if (tag != null)
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: AppStatusBadge(label: tag!, tone: tagTone),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: c.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              price,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: c.primary,
                              ),
                            ),
                            if (originalPrice != null)
                              Text(
                                originalPrice!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: c.onSurfaceVariant,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (onAddToCart != null)
                        IconButton.filledTonal(
                          tooltip: 'Thêm vào giỏ',
                          onPressed: onAddToCart,
                          icon: const Icon(Icons.add_shopping_cart),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
