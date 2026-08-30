String normalizeRemoteImageUrl(Object? value) {
  final text = value?.toString().trim() ?? '';
  final uri = Uri.tryParse(text);

  if (uri == null ||
      uri.host.isEmpty ||
      (uri.scheme != 'http' && uri.scheme != 'https')) {
    return '';
  }

  return text;
}

List<String> normalizeRemoteImageUrls(Object? value) {
  final values = value is List ? value : [value];
  final urls = <String>[];
  final seen = <String>{};

  for (final item in values) {
    final url = normalizeRemoteImageUrl(item);
    if (url.isNotEmpty && seen.add(url)) urls.add(url);
  }

  return List.unmodifiable(urls);
}

/// Uses Supabase's image transformation endpoint when the URL is a public
/// Storage object. Other hosts are returned unchanged and are handled by the
/// viewport/cache safeguards in the image widget.
String responsiveImageUrl(
  String url, {
  int? width,
  int? height,
  bool crop = false,
}) {
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.host.endsWith('.supabase.co')) return url;

  const objectPrefix = '/storage/v1/object/public/';
  const renderPrefix = '/storage/v1/render/image/public/';
  final path = uri.path;
  final objectIndex = path.indexOf(objectPrefix);

  if (objectIndex < 0 || path.startsWith(renderPrefix)) return url;

  final objectPath = path.substring(objectIndex + objectPrefix.length);
  if (objectPath.isEmpty || (width == null && height == null)) return url;

  return uri
      .replace(
        path: '$renderPrefix$objectPath',
        queryParameters: {
          ...uri.queryParameters,
          if (width != null) 'width': width.toString(),
          if (height != null) 'height': height.toString(),
          'resize': crop ? 'cover' : 'contain',
          'quality': '80',
        },
      )
      .toString();
}
