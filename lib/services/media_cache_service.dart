import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MediaCacheService {
  final BaseCacheManager _cache = DefaultCacheManager();

  Future<void> prefetchAll(List<String> urls) async {
    for (final url in urls) {
      try {
        await _cache.downloadFile(url);
      } catch (_) {}
    }
  }

  Future<File?> getCachedFile(String url) async {
    try {
      final info = await _cache.getFileFromCache(url);
      return info?.file;
    } catch (_) {
      return null;
    }
  }
}


