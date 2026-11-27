import 'package:flutter/material.dart';

enum AppAvatarSize {
  small(32),
  medium(40),
  large(56),
  extraLarge(96);

  const AppAvatarSize(this.value);
  final double value;
}

/// Circular avatar: shows [imageUrl], falling back to initials from [name],
/// then to a person icon.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.icon = Icons.person_outline,
    this.size = AppAvatarSize.medium,
    this.onTap,
  });

  final String? imageUrl;
  final String? name;
  final IconData icon;
  final AppAvatarSize size;
  final VoidCallback? onTap;

  String? get _initials {
    final parts = (name ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty);
    if (parts.isEmpty) return null;
    final letters = parts.length == 1
        ? parts.first.substring(0, 1)
        : '${parts.first[0]}${parts.last[0]}';
    return letters.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final initials = _initials;
    final avatar = CircleAvatar(
      radius: size.value / 2,
      backgroundColor: c.primaryContainer,
      foregroundColor: c.onPrimaryContainer,
      foregroundImage: hasImage
          ? NetworkImage(
              imageUrl!,
              webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
            )
          : null,
      onForegroundImageError: hasImage ? (_, _) {} : null,
      child: initials != null
          ? Text(initials, style: TextStyle(fontSize: size.value * 0.4))
          : Icon(icon, size: size.value * 0.55),
    );
    final labelled = Semantics(label: name, image: true, child: avatar);
    if (onTap == null) return labelled;
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: labelled,
    );
  }
}
