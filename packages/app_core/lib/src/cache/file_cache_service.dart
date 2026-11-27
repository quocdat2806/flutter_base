import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'dio_file_service.dart';

/// Disk cache for binary files (images, PDF, audio), shared with
/// `cached_network_image` through [AppNetworkImage].
///
/// * [publicFiles] – not tied to the user (doctor photos, banners). Kept on
///   logout, never sends the token.
/// * [privateFiles] – needs the token (prescription PDF, invoices, user
///   uploads). Wiped on logout and at least every
///   [CacheTtl.privateFilesMaxAge] by `SessionCacheGuard`.
///
/// Files are keyed by URL. When private files move to S3 presigned URLs
/// (which change every time), pass a stable `key` (the file id) to
/// [getFilePath].
final class FileCacheService {
  FileCacheService({required Dio dio, required Uri apiBaseUri})
    : publicFiles = CacheManager(
        Config(
          'public_files',
          stalePeriod: const Duration(days: 7),
          maxNrOfCacheObjects: 300,
          fileService: DioFileService(
            dio,
            apiBaseUri: apiBaseUri,
            authenticate: false,
            validFor: const Duration(days: 7),
          ),
        ),
      ),
      privateFiles = CacheManager(
        Config(
          'private_files',
          stalePeriod: CacheTtl.privateFilesMaxAge,
          maxNrOfCacheObjects: 100,
          fileService: DioFileService(
            dio,
            apiBaseUri: apiBaseUri,
            authenticate: true,
            validFor: CacheTtl.privateFilesMaxAge,
          ),
        ),
      );

  final CacheManager publicFiles;
  final CacheManager privateFiles;

  CacheManager manager({required bool private}) =>
      private ? privateFiles : publicFiles;

  /// Local path of [url], downloading it first if needed. Use for PDF /
  /// audio players that take a file path.
  Future<String> getFilePath(
    String url, {
    bool private = false,
    String? key,
  }) async =>
      (await manager(private: private).getSingleFile(url, key: key)).path;

  /// Deletes every private file (logout, 24h limit).
  Future<void> clearPrivate() => privateFiles.emptyCache();
}
