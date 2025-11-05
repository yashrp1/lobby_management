# Technical Documentation

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


