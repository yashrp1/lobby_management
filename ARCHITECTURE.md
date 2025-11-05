# Project Architecture

This project follows a pragmatic Clean Architecture with clear separation of concerns:

- core/
  - constants/ – app-wide constants
  - di/ – dependency injection (get_it)
  - theme/ – Material 3 theming
  - utils/ – cross-cutting concerns (logging, performance, validators, secure storage, image cache)
- data/
  - datasources/ – remote/local data access (Dio, etc.)
  - models/ – DTOs/entities with parsers
  - repository/ – implementation of domain-facing repositories
- domain/ (optional for future)
  - repositories/ – abstract contracts
  - usecases/ – application business rules
- presentation/
  - bloc/ – Cubits/States
  - screens/ – screens
  - widgets/ – widgets
- services/
  - navigation/share/connectivity – platform-facing services behind interfaces

## Dependency Direction
presentation → domain (contracts) → data (repo impl → datasource)

UI never depends directly on Dio. All edges are injected via `core/di/injector.dart`.

```
presentation  -->  domain (contracts)  -->  data (repos -> datasources)
     |                                           ^
     └--------------------- core (utils, DI, logging) ----------------------┘
```

## Error Handling
- Typed exceptions in `core/utils/api_exception.dart`
- Data layer throws domain-safe exceptions; UI renders friendly messages + retry
- Logging: `core/utils/logger.dart` with masked sensitive headers

## Performance
- `RepaintBoundary` on heavy sections; optimized image cache (50MB)
- `PerformanceMonitor` logs operation timings
- HTTP cache headers; lazy loading; placeholders

### UI Performance Practices
- Prefer `CustomScrollView` + slivers for long scroll surfaces
- Avoid unnecessary rebuilds; keep widget trees shallow
- Use `FadeInAnimation` and shimmer loaders to hide content pops

## Security
- No hardcoded keys; dynamic headers
- `SecureStorage` for sensitive data
- Input sanitization + validation
- Certificate pinning scaffold (optional)

## DI
- `core/di/injector.dart` registers Dio, datasources, repositories
- `main.dart` resolves repository from `getIt`

## Services Layer
- Thin, testable adapters for platform APIs (navigation/share/connectivity)
- Keep UI lean; swap implementations easily for tests
