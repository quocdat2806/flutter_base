import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// [FileService] that downloads through the app's [Dio], so private files
/// get the auth header, token refresh and retries of [ApiClient].
///
/// The token is only sent when [authenticate] is true **and** the file is on
/// the API's own origin: `AuthInterceptor` attaches it to any request that
/// asks for it, so a CDN / third-party URL must never ask.
final class DioFileService extends FileService {
  DioFileService(
    this._dio, {
    required this.apiBaseUri,
    required this.authenticate,
    required this.validFor,
  });

  final Dio _dio;
  final Uri apiBaseUri;
  final bool authenticate;

  /// How long a downloaded file is considered valid. The backend sends no
  /// `Cache-Control`, so this replaces it.
  final Duration validFor;

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final uri = apiBaseUri.resolve(url);
    final response = await _dio.getUri<ResponseBody>(
      uri,
      options: apiOptions(
        requiresAuth: authenticate && uri.origin == apiBaseUri.origin,
        headers: headers,
        responseType: ResponseType.stream,
      ),
    );
    return _DioFileResponse(response, uri, DateTime.now().add(validFor));
  }
}

final class _DioFileResponse implements FileServiceResponse {
  _DioFileResponse(this._response, this._uri, this.validTill);

  final Response<ResponseBody> _response;
  final Uri _uri;

  @override
  final DateTime validTill;

  @override
  Stream<List<int>> get content => _response.data!.stream;

  @override
  int? get contentLength {
    final length = _response.data!.contentLength;
    return length < 0 ? null : length;
  }

  @override
  int get statusCode => _response.statusCode ?? 200;

  @override
  String? get eTag => _response.headers.value('etag');

  @override
  String get fileExtension =>
      _extensionFor(_response.headers.value(Headers.contentTypeHeader), _uri);
}

const _mimeExtensions = {
  'application/pdf': '.pdf',
  'image/jpeg': '.jpg',
  'image/png': '.png',
  'image/webp': '.webp',
  'image/gif': '.gif',
  'image/heic': '.heic',
  'audio/mpeg': '.mp3',
  'audio/mp4': '.m4a',
  'audio/aac': '.aac',
  'video/mp4': '.mp4',
};

final _safeExtension = RegExp(r'^\.[A-Za-z0-9]{1,10}$');

/// Picks the file extension from the content type, then the URL path, then
/// falls back to `.bin`.
String _extensionFor(String? contentType, Uri uri) {
  final mime = contentType?.split(';').first.trim().toLowerCase();
  final fromMime = _mimeExtensions[mime];
  if (fromMime != null) return fromMime;

  final name = uri.pathSegments.isEmpty ? '' : uri.pathSegments.last;
  final dot = name.lastIndexOf('.');
  if (dot > 0) {
    final ext = name.substring(dot).toLowerCase();
    if (_safeExtension.hasMatch(ext)) return ext;
  }
  return '.bin';
}
