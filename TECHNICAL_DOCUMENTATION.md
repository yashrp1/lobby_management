# Technical Documentation

## State management approach
- Library: `flutter_bloc` (Cubit)
- Pattern: Presentation logic in Cubits, immutable states in `presentation/bloc/...`
- Rationale: Simple, testable, minimal boilerplate, easy side-effect handling
- Example: `EventDetailCubit` loads event data, emits loading/error/loaded. Periodic timers simulate "viewing now" and participant updates, and are disposed in `close()`.

Guidelines:
- Keep Cubits lean; delegate I/O to repositories
- Emit states only after data integrity checks
- Cancel timers/streams in `close()` to avoid leaks

Key files:
- `lib/presentation/bloc/event_detail/event_detail_cubit.dart`
- `lib/presentation/bloc/event_detail/event_detail_state.dart`

## API integration strategy
- HTTP client: `Dio` with sane timeouts and sanitized logging
- Flow: Repository → Datasource (Dio) → parse DTOs → UI models
- Errors: Datasource throws typed `ApiException`s; UI renders friendly messages with retry
- DI: All edges resolved via `get_it` in `core/di/injector.dart`

Key files:
- `lib/data/datasources/event_remote_datasource.dart`
- `lib/data/repository/event_repository.dart`
- `lib/core/di/injector.dart`

## Challenges faced and solutions
1) Connectivity API variance (`connectivity_plus` versions)
   - Solution: Normalized `onConnectivityChanged` to always emit a single `ConnectivityResult` in `ConnectivityService`.
2) Image-heavy header causing repaints
   - Solution: Wrap media in `RepaintBoundary`, constrain memory cache, and use sized `memCacheWidth/Height`.
3) Offline UX without blocking navigation
   - Solution: Inline banner for offline state; show No-Internet screen only if offline AND no cached data.
4) Offline media when the user returns
   - Solution: Prefetch images on first online view; offline loaders check disk cache and render `Image.file`.
5) Safe live updates without server push
   - Solution: Timed simulations in Cubit with immutable `copyWith` updates on models.

## Performance optimization techniques used
- Startup
  - `PerformanceMonitor` timers around initialization and first data load
  - Avoid blocking operations in `main()`; configure image cache early
- Scrolling smoothness (60fps)
  - `CustomScrollView` + slivers; `RepaintBoundary` around large images and carousels
- Image efficiency
  - Global image cache cap (~50MB); sized `memCacheWidth/Height`; disk cache max dimensions
  - Lightweight placeholders and shimmer for skeleton loading
- Memory usage
  - Dispose timers/controllers; avoid storing heavy objects in state
  - Keep widget trees shallow; use animations with short durations

### Media Experience
- Header carousel uses `carousel_slider` with `onPageChanged` to track index.
- Indicators: `AnimatedSmoothIndicator` (WormEffect) overlaid at the bottom of the header.
- Full-screen viewer: `ImageGalleryViewer` built with `PhotoViewGallery` for pinch-to-zoom and swipe.
- Offline-aware media:
  - Prefetch via `MediaCacheService.prefetchAll(urls)` when online.
  - When offline, both header and gallery attempt `MediaCacheService.getCachedFile(url)` and render `Image.file`.

## State Management Approach

- Library: `flutter_bloc` (Cubit)
- Pattern: Presentation logic in Cubits, immutable states in `presentation/bloc/...`
- Rationale: Simple, testable, minimal boilerplate, easy side-effect handling
- Example: `EventDetailCubit` loads event data, exposes loading/error/loaded states

Guidelines:
- Keep Cubits lean; delegate I/O to repositories
- Emit states only after data integrity checks
- Cancel timers/streams in `close()` to avoid leaks

## API Integration Strategy

- HTTP client: `Dio` with sane timeouts
- Data flow: Repository → Datasource (Dio) → parse DTOs → domain-safe models
- Error mapping: Datasource throws `ApiException`; UI translates to friendly messages
- Logging: `AppLogger.apiRequest/apiResponse` with sanitized headers
- DI: All edges resolved from `get_it` in `core/di/injector.dart`

Resilience:
- Connectivity-aware UI via `ConnectivityGate`; retry flows in UI
- Cache headers respected; images aggressively cached via `CachedNetworkImage`

## Challenges & Solutions

1) Connectivity API changes (`connectivity_plus`)
- Challenge: Different versions may return `ConnectivityResult` or `List<ConnectivityResult>`
- Solution: Normalized `ConnectivityService.check()` and `onConnectivityChanged` to a single `ConnectivityResult`

2) Jank risk on image-heavy header
- Challenge: Large carousel images can trigger expensive repaints
- Solution: Wrap items in `RepaintBoundary`, cap memory cache, provide `memCacheWidth/Height`

3) Cold-start time budget (≤ 2s)
- Challenge: Data fetch + image decode could extend first paint
- Solution: Start performance timer, lazy-load below-the-fold content, lightweight placeholders, avoid synchronous heavy work in `main()`

## Performance Optimization Techniques

- Startup
  - `PerformanceMonitor` timers around initialization and first data load, warn >2000ms
  - Avoid blocking operations in `main()`, configure image cache early

- Scrolling smoothness (60fps)
  - `CustomScrollView` with slivers; minimal overdraw; `BouncingScrollPhysics`
  - `RepaintBoundary` around carousel and large images

- Image efficiency
  - `ImageCacheConfig` sets global cache size (~50MB)
  - `CachedNetworkImage` with sized `memCacheWidth/Height` and disk cache limits
  - Lightweight shimmer/placeholder to hide layout shift

- Memory (<150MB target)
  - Capped image cache; avoid storing large lists in state
  - Dispose timers/streams; avoid retaining contexts

## Logging & Diagnostics

- `AppLogger` centralized logging with masked sensitive data
- `PerformanceMonitor.performance()` emits per-op timings
- Snackbars for user-facing errors with retry actions

## Testing Pointers

- Unit-test Cubits with fake repositories
- Widget-test screens with mocked Cubit states
- Integration-test repository with mocked Dio responses


