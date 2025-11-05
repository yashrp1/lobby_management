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
    // Guard against Infinity/NaN explicit dimensions
    final double? safeWidth = (width != null && width.isFinite && width > 0) ? width : null;
    final double? safeHeight = (height != null && height.isFinite && height > 0) ? height : null;

    int? safeCacheDim(double? logicalPx, double devicePixelRatio) {
      if (logicalPx == null) return null;
      if (!logicalPx.isFinite || logicalPx <= 0) return null;
      final px = (logicalPx * devicePixelRatio).round();
      return px;
    }

    // If explicit width is provided, use it; otherwise compute from layout constraints
    if (safeWidth != null || safeHeight != null) {
      return Builder(
        builder: (context) {
          final dpr = MediaQuery.of(context).devicePixelRatio;
          final scheme = Theme.of(context).colorScheme;
          return CachedNetworkImage(
            imageUrl: imageUrl,
            fit: fit,
            width: safeWidth,
            height: safeHeight,
            placeholder: placeholder ??
                (context, url) => Container(
                      color: scheme.surfaceContainerHighest,
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
            errorWidget: errorWidget ??
                (context, url, error) => Container(
                      color: scheme.surfaceContainerHighest,
                      child: Icon(Icons.error_outline, color: scheme.onSurfaceVariant),
                    ),
            memCacheWidth: safeCacheDim(safeWidth, dpr),
            memCacheHeight: safeCacheDim(safeHeight, dpr),
            maxWidthDiskCache: safeCacheDim(safeWidth ?? 1000, dpr),
            maxHeightDiskCache: safeCacheDim(safeHeight ?? 1000, dpr),
            fadeInDuration: const Duration(milliseconds: 150),
            fadeOutDuration: const Duration(milliseconds: 80),
          );
        },
      );
    }

    // No explicit dimensions: infer from layout to request device-appropriate sizes
    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.of(context).devicePixelRatio;
        final logicalW = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final logicalH = constraints.maxHeight.isFinite && constraints.maxHeight > 0
            ? constraints.maxHeight
            : null;
        final memW = safeCacheDim(logicalW, dpr);
        final memH = logicalH != null ? safeCacheDim(logicalH, dpr) : null;
        final diskW = memW != null ? memW.clamp(360, 1600) as int : 1000;
        final diskH = memH != null ? memH.clamp(360, 1600) as int : 1000;

        final scheme = Theme.of(context).colorScheme;
        return CachedNetworkImage(
          imageUrl: imageUrl,
          fit: fit,
          placeholder: placeholder ??
              (context, url) => Container(
                    color: scheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
          errorWidget: errorWidget ??
              (context, url, error) => Container(
                    color: scheme.surfaceContainerHighest,
                    child: Icon(Icons.error_outline, color: scheme.onSurfaceVariant),
                  ),
          memCacheWidth: memW,
          memCacheHeight: memH,
          maxWidthDiskCache: diskW,
          maxHeightDiskCache: diskH,
          fadeInDuration: const Duration(milliseconds: 150),
          fadeOutDuration: const Duration(milliseconds: 80),
        );
      },
    );
  }
}

