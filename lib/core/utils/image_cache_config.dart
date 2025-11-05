import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Image cache configuration for optimal performance
class ImageCacheConfig {
  /// Configure image cache settings for optimal memory usage
  static void configure() {
    // Set maximum cache size (50MB for images)
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50MB
  }

  /// Get optimized CachedNetworkImage widget with performance settings
  static Widget getOptimizedImage({
    required String imageUrl,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    PlaceholderWidgetBuilder? placeholder,
    LoadingErrorWidgetBuilder? errorWidget,
  }) {
    // Guard against Infinity/NaN dimensions coming from layout queries
    final double? safeWidth = (width != null && width.isFinite && width > 0)
        ? width
        : null;
    final double? safeHeight = (height != null && height.isFinite && height > 0)
        ? height
        : null;

    int? safeCacheDim(double? value) {
      if (value == null) return null;
      if (!value.isFinite || value <= 0) return null;
      return value.round();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: safeWidth,
      height: safeHeight,
      placeholder: placeholder ??
          (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
      errorWidget: errorWidget ??
          (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.error_outline, color: Colors.grey),
              ),
      // Performance optimizations
      memCacheWidth: safeCacheDim(safeWidth),
      memCacheHeight: safeCacheDim(safeHeight),
      maxWidthDiskCache: 1000,
      maxHeightDiskCache: 1000,
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }
}

