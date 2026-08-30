import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sukonlanat_portfolio/utils/image_url.dart';

/// Displays a remote image without decoding it larger than the space it uses.
///
/// The same image can be shown as a card thumbnail and as a full-screen image.
/// Giving each use its own decode limit keeps thumbnails cheap while allowing
/// the viewer to retain enough detail for zooming.
class OptimizedNetworkImage extends StatelessWidget {
  const OptimizedNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.maxDecodeDimension = 2048,
    this.filterQuality = FilterQuality.medium,
    this.errorIconSize = 48,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final int maxDecodeDimension;
  final FilterQuality filterQuality;
  final double errorIconSize;

  bool get _hasValidUrl {
    final uri = Uri.tryParse(url.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  int? _decodeDimension(double value, double devicePixelRatio) {
    if (!value.isFinite || value <= 0) return null;

    return math.min(
      maxDecodeDimension,
      math.max(1, (value * devicePixelRatio).ceil()),
    );
  }

  Widget _errorWidget() {
    return Center(
      child: Icon(Icons.image_not_supported_outlined, size: errorIconSize),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasValidUrl) return _errorWidget();

    return LayoutBuilder(
      builder: (context, constraints) {
        final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
        final cacheWidth = _decodeDimension(
          constraints.maxWidth,
          devicePixelRatio,
        );
        final cacheHeight = _decodeDimension(
          constraints.maxHeight,
          devicePixelRatio,
        );

        final transformedUrl = responsiveImageUrl(
          url,
          width: cacheWidth,
          height: cacheHeight,
          crop: fit == BoxFit.cover,
        );

        return _buildNetworkImage(
          sourceUrl: transformedUrl,
          originalUrl: url,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
        );
      },
    );
  }

  Widget _buildNetworkImage({
    required String sourceUrl,
    required String originalUrl,
    required double? width,
    required double? height,
    required BoxFit fit,
    required Alignment alignment,
    required int? cacheWidth,
    required int? cacheHeight,
  }) {
    return Image.network(
      sourceUrl,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      filterQuality: filterQuality,
      gaplessPlayback: true,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const _ImageLoadingPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        if (sourceUrl != originalUrl) {
          return _buildNetworkImage(
            sourceUrl: originalUrl,
            originalUrl: originalUrl,
            width: width,
            height: height,
            fit: fit,
            alignment: alignment,
            cacheWidth: cacheWidth,
            cacheHeight: cacheHeight,
          );
        }

        return _errorWidget();
      },
    );
  }
}

class _ImageLoadingPlaceholder extends StatelessWidget {
  const _ImageLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black12,
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
