# Lobby Management (Flutter)

Production-ready Flutter app demonstrating pragmatic Clean Architecture, strong performance, and robust error handling.

## Requirements

- Flutter 3.19+ (stable)
- Dart 3+
- Xcode 14+ (for iOS)
- Android Studio / Android SDK 33+

## Setup

1) Clone and fetch packages

```bash
flutter pub get
```

2) Generate platform artifacts (first run)

```bash
flutter create .
```

3) Run

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# Web (optional)
flutter run -d chrome
```

## Build

```bash
# Android APK (release)
flutter build apk --release

# iOS (release)
flutter build ios --release
```

## Lint & Format

```bash
flutter analyze
dart format .
```

## Tests

```bash
flutter test
```

## Configuration

- App theming: `lib/core/theme/app_theme.dart`
- Dependency injection: `lib/core/di/injector.dart`
- Environment constants: `lib/core/constants/`

## Performance Targets (enforced in dev)

- App cold start under 2 seconds on 4G
- Smooth 60fps scrolling (heavy sections wrapped in `RepaintBoundary`)
- Efficient image caching (global 50MB cap, sized memory cache)
- Memory usage under 150MB (dev logging via `PerformanceMonitor`)

## Offline Handling

- Connectivity gate shows a dedicated No-Internet screen with retry
- File: `lib/presentation/widgets/connectivity_gate.dart`

## Architecture Overview

See `ARCHITECTURE.md` for full details. High-level layout:

- `core/` cross-cutting concerns (DI, logging, performance, theming)
- `data/` datasources and repository implementations
- `domain/` contracts (optionally expanded with use cases)
- `presentation/` UI, widgets, and Cubit-based state management

## Technical Documentation

See `TECHNICAL_DOCUMENTATION.md` for:

- State management approach
- API integration strategy
- Challenges and solutions
- Performance optimization techniques
