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
  @override
  void initState() {
    super.initState();
    context.read<EventDetailCubit>().loadEventDetail(widget.eventId, widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            return _buildContent(state.event, state.viewingCount);
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
                  icon: const Icon(Icons.bookmark_border, color: Colors.white),
                  onPressed: () {
                    MicroInteractions.selection(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Bookmark button pressed'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Spacing.sm),
                        ),
                      ),
                    );
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
                  onPressed: () {
                    MicroInteractions.buttonPress(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Share button pressed'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Spacing.sm),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: lobby.mediaUrls.isNotEmpty
                  ? RepaintBoundary(
                      child: CarouselSlider.builder(
                        itemCount: lobby.mediaUrls.length,
                        itemBuilder: (context, index, realIndex) {
                          return RepaintBoundary(
                            child: ImageCacheConfig.getOptimizedImage(
                              imageUrl: lobby.mediaUrls[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          );
                        },
                        options: CarouselOptions(
                          height: double.infinity,
                          viewportFraction: 1.0,
                          autoPlay: lobby.mediaUrls.length > 1,
                          autoPlayInterval: const Duration(seconds: 4),
                          enableInfiniteScroll: false,
                        ),
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
}

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Details')),
      body: ListView(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
              color: Colors.white,
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
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
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
