extension UriExt on Uri {
  /// Thêm query parameters vào URI hiện tại.
  Uri addQueryParameters(Map<String, String> params) {
    return replace(queryParameters: {...queryParameters, ...params});
  }

  /// Lấy file extension: "photo.jpg" → "jpg"
  String? get fileExtension {
    final segments = pathSegments;
    if (segments.isEmpty) return null;
    final lastSegment = segments.last;
    final dotIndex = lastSegment.lastIndexOf('.');
    if (dotIndex == -1) return null;
    return lastSegment.substring(dotIndex + 1).toLowerCase();
  }

  /// Lấy filename: "/uploads/photo.jpg" → "photo.jpg"
  String? get fileName {
    final segments = pathSegments;
    return segments.isNotEmpty ? segments.last : null;
  }
}
