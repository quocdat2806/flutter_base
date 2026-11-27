import 'package:flutter/material.dart';

/// Network or asset image with loading placeholder, error fallback and
/// optional rounded corners. Uses [url] when it starts with http(s),
/// otherwise treats it as an asset path.
class AppImage extends StatelessWidget {
  const AppImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.semanticLabel,
    this.placeholder,
    this.errorWidget,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? semanticLabel;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    final src = url;
    Widget image;
    if (src == null || src.isEmpty) {
      image = _fallback(context);
    } else if (src.startsWith('http://') || src.startsWith('https://')) {
      image = Image.network(
        src,
        // On web (CanvasKit), fall back to an <img> element when the host
        // doesn't send CORS headers instead of failing to load.
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: semanticLabel,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : (placeholder ?? _placeholder(context)),
        errorBuilder: (context, _, _) => _fallback(context),
      );
    } else {
      image = Image.asset(
        src,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: semanticLabel,
        errorBuilder: (context, _, _) => _fallback(context),
      );
    }
    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }

  Widget _placeholder(BuildContext context) => Container(
    width: width,
    height: height,
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
  );

  Widget _fallback(BuildContext context) =>
      errorWidget ??
      Container(
        width: width,
        height: height,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
}
