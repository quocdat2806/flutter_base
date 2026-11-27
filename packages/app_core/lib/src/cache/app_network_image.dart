import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'file_cache_service.dart';

/// Network image backed by [FileCacheService]. Use instead of
/// `CachedNetworkImage` so every image goes through the shared cache and
/// private images get the auth token.
///
/// Needs a [FileCacheService] above it (`RepositoryProvider`).
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage(
    this.url, {
    super.key,
    this.private = false,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.error,
  });

  final String url;

  /// `true` for images that need the user's token (wiped on logout).
  final bool private;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? error;

  @override
  Widget build(BuildContext context) {
    final files = context.read<FileCacheService>();
    return CachedNetworkImage(
      imageUrl: url,
      cacheManager: files.manager(private: private),
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder == null ? null : (_, _) => placeholder!,
      errorWidget: error == null ? null : (_, _, _) => error!,
    );
  }
}
