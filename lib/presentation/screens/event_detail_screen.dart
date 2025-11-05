import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/animations.dart';
import '../../core/utils/image_cache_config.dart';
import '../../core/constants/spacing.dart';
import '../bloc/event_detail/event_detail_cubit.dart';
import '../bloc/event_detail/event_detail_state.dart';
import '../widgets/event_detail_content.dart';
import '../../services/saved_events_service.dart';
import '../../services/share_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/di/injector.dart';
import '../../services/connectivity_service.dart';
import '../../services/media_cache_service.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'image_gallery_viewer.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  final String? token;

  const EventDetailScreen({
    super.key,
    required this.eventId,
    this.token,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isSaved = false;
  ConnectivityResult? _conn;
  bool _mediaPrefetched = false;
  int _currentImage = 0;

  @override
  void initState() {
    super.initState();
    context.read<EventDetailCubit>().loadEventDetail(widget.eventId, widget.token);
    _loadSavedState();
    _checkConnectivity();
  }

  Future<void> _loadSavedState() async {
    final saved = await SavedEventsService.isSaved(widget.eventId);
    if (mounted) {
      setState(() {
        _isSaved = saved;
      });
    }
  }

  Future<void> _checkConnectivity() async {
    final service = getIt.get<ConnectivityService>();
    final result = await service.check();
    if (mounted) setState(() => _conn = result);
    service.onConnectivityChanged.listen((event) {
      if (!mounted) return;
      setState(() => _conn = event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocConsumer<EventDetailCubit, EventDetailState>(
        listener: (context, state) {
          if (state is EventDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                action: SnackBarAction(
                  label: 'Retry',
                  onPressed: () {
                    context.read<EventDetailCubit>().loadEventDetail(
                          widget.eventId,
                          widget.token,
                        );
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is EventDetailLoading) {
            return _LoadingView();
          }

          if (state is EventDetailError) {
            return _ErrorView(
              message: state.message,
              onRetry: () {
                context.read<EventDetailCubit>().loadEventDetail(
                      widget.eventId,
                      widget.token,
                    );
              },
            );
          }

          if (state is EventDetailLoaded) {
            // Prefetch media for offline viewing when online (run once)
            if (!_mediaPrefetched && _conn != ConnectivityResult.none) {
              _mediaPrefetched = true;
              final media = state.event.lobby.mediaUrls;
              if (media.isNotEmpty) {
                getIt.get<MediaCacheService>().prefetchAll(media);
              }
            }

            final content = _buildContent(state.event, state.viewingCount);
            return Stack(
              children: [
                content,
                if (_conn == ConnectivityResult.none)
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_off, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Offline mode', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(dynamic event, int viewingCount) {
    final lobby = event.lobby;
    return SafeArea(
      top: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header with image
          SliverAppBar(
            expandedHeight: Responsive.isTablet(context)
                ? MediaQuery.of(context).size.height * 0.5
                : MediaQuery.of(context).size.height * 0.45,
            pinned: true,
            backgroundColor: Colors.black,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  MicroInteractions.buttonPress(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Back button pressed'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Spacing.sm),
                      ),
                    ),
                  );
                  // Navigator.of(context).pop();
                },
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border, color: Colors.white),
                  onPressed: () async {
                    MicroInteractions.selection(context);
                    await SavedEventsService.toggleSaved(widget.eventId);
                    final nowSaved = await SavedEventsService.isSaved(widget.eventId);
                    if (mounted) {
                      setState(() {
                        _isSaved = nowSaved;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(nowSaved ? 'Saved to favorites' : 'Removed from favorites'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Spacing.sm),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () async {
                    MicroInteractions.buttonPress(context);
                    final shareText = _buildShareText(event);
                    await ShareServiceImpl().shareText(
                      shareText,
                      subject: 'Check out this event: ${event.lobby.title}',
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: lobby.mediaUrls.isNotEmpty
                  ? RepaintBoundary(
                      child: Stack(
                        children: [
                          CarouselSlider.builder(
                        itemCount: lobby.mediaUrls.length,
                        itemBuilder: (context, index, realIndex) {
                          final url = lobby.mediaUrls[index];
                              final imageWidget = _conn == ConnectivityResult.none
                                  ? FutureBuilder(
                                      future: getIt.get<MediaCacheService>().getCachedFile(url),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                                          return Image.file(snapshot.data!, fit: BoxFit.cover, width: double.infinity);
                                        }
                                        return ImageCacheConfig.getOptimizedImage(
                                          imageUrl: url,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        );
                                      },
                                    )
                                  : ImageCacheConfig.getOptimizedImage(
                                      imageUrl: url,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    );
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => ImageGalleryViewer(
                                      imageUrls: lobby.mediaUrls,
                                      initialIndex: index,
                                    ),
                                  ));
                                },
                                child: imageWidget,
                              );
                            },
                            options: CarouselOptions(
                              height: double.infinity,
                              viewportFraction: 1.0,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 6),
                              enableInfiniteScroll: false,
                              onPageChanged: (idx, reason) {
                                setState(() => _currentImage = idx);
                              },
                            ),
                          ),
                          if (lobby.mediaUrls.length > 1)
                            Positioned(
                              bottom: 12,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: AnimatedSmoothIndicator(
                                  activeIndex: _currentImage,
                                  count: lobby.mediaUrls.length,
                                  effect: const WormEffect(
                                    dotWidth: 8,
                                    dotHeight: 8,
                                    activeDotColor: Colors.white,
                                    dotColor: Colors.white54,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image, size: 64, color: Colors.grey),
                      ),
                    ),
            ),
          ),
          
          // Content section with responsive width
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Responsive.getContentWidth(context),
                ),
                child: FadeInAnimation(
                  child: EventDetailContent(
                    event: event,
                    viewingCount: viewingCount,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildShareText(dynamic event) {
    final lobby = event.lobby;
    final dateStr = lobby.dateRange != null
        ? lobby.dateRange!.formattedDate ?? lobby.dateRange!.startDateTime.toString()
        : '';
    final location = lobby.filter?.otherFilterInfo?.locationInfo?.firstLocation?.displayAddress ?? '';
    final link = 'https://event.app/e/${lobby.id}?utm_source=share&utm_medium=app';
    final lines = <String>[
      lobby.title,
      if (dateStr.isNotEmpty) 'When: $dateStr',
      if (location.isNotEmpty) 'Where: $location',
      'Join here: $link',
    ];
    return lines.join('\n');
  }
}

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Details')),
      body: ListView(
        children: [
          Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            highlightColor: Theme.of(context).colorScheme.surface,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    highlightColor: Theme.of(context).colorScheme.surface,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Details')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
