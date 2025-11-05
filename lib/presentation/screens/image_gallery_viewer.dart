import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/di/injector.dart';
import '../../services/media_cache_service.dart';
import '../../services/connectivity_service.dart';

class ImageGalleryViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageGalleryViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<ImageGalleryViewer> createState() => _ImageGalleryViewerState();
}

class _ImageGalleryViewerState extends State<ImageGalleryViewer> {
  late final PageController _pageController;
  int _current = 0;
  ConnectivityResult? _conn;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex.clamp(0, widget.imageUrls.length - 1);
    _pageController = PageController(initialPage: _current);
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    final service = getIt.get<ConnectivityService>();
    final status = await service.check();
    if (mounted) setState(() => _conn = status);
    service.onConnectivityChanged.listen((event) {
      if (!mounted) return;
      setState(() => _conn = event);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: widget.imageUrls.length,
            builder: (context, index) {
              final url = widget.imageUrls[index];
              return PhotoViewGalleryPageOptions.customChild(
                child: _buildImage(url),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3.0,
                heroAttributes: PhotoViewHeroAttributes(tag: 'gallery_$index'),
              );
            },
            onPageChanged: (i) => setState(() => _current = i),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_current + 1}/${widget.imageUrls.length}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url) {
    if (_conn == ConnectivityResult.none) {
      return FutureBuilder<File?>(
        future: getIt.get<MediaCacheService>().getCachedFile(url),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
            return Image.file(snapshot.data!, fit: BoxFit.contain);
          }
          return const Center(child: Icon(Icons.image_not_supported, color: Colors.white54, size: 48));
        },
      );
    }
    return Image.network(url, fit: BoxFit.contain);
  }
}


