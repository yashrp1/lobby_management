# Lobby Management (Flutter)

This repository contains a Flutter app with a clean architecture foundation.

## Requirements

- Flutter 3.19+ (stable)
- Dart 3+

## Setup

1) Install dependencies

```bash
flutter pub get
```

2) Generate platform builds (first run)

```bash
flutter create .
```

3) Run the app

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android
```

## Build

```bash
# Android APK (release)
flutter build apk --release

# iOS (release)
flutter build ios --release
```

## Lint & Tests

```bash
flutter analyze
flutter test
```

For architecture and technical details, see `ARCHITECTURE.md` and `TECHNICAL_DOCUMENTATION.md`.
