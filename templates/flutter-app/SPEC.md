# Flutter App Template Specification

## Overview

This is a production-ready Flutter application template using modern Flutter 3.x architecture patterns. It provides a solid foundation for building scalable mobile applications with clean architecture principles.

## Technology Stack

### Core Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | ^2.4.9 | State management |
| go_router | ^13.0.0 | Declarative routing |
| dio | ^5.4.0 | HTTP client |
| freezed | ^2.4.6 | Immutable data classes |
| json_annotation | ^4.8.1 | JSON serialization annotations |
| fl_chart | ^0.66.0 | Charts and graphs |
| flutter_screenutil | ^5.9.0 | Responsive UI |
| shared_preferences | ^2.2.2 | Local storage |
| path_provider | ^2.1.2 | File system paths |
| permission_handler | ^11.2.0 | Runtime permissions |
| audioplayers | ^5.2.1 | Audio playback |
| lottie | ^3.0.0 | animations |
| webview_flutter | ^4.4.2 | WebView widget |
| build_runner | ^2.4.8 | Code generation |
| json_serializable | ^6.7.1 | JSON serialization |

### SDK Requirements
- Dart SDK: `>=3.0.0 <4.0.0`
- Flutter SDK: `>=3.0.0`

## Architecture

### Clean Architecture Structure
```
lib/
├── core/                    # Shared infrastructure
│   ├── config/              # App configuration
│   ├── network/             # Dio HTTP client, interceptors
│   ├── storage/             # Local storage abstractions
│   └── router/              # GoRouter configuration
├── features/                # Feature modules
│   └── example/             # Example feature
│       ├── data/            # Data layer
│       │   ├── datasources/ # Remote/local data sources
│       │   ├── models/      # DTOs with JSON serialization
│       │   └── repositories/# Repository implementations
│       ├── domain/          # Business logic layer
│       │   ├── entities/    # Business entities
│       │   ├── repositories/# Repository interfaces
│       │   └── usecases/    # Business use cases
│       └── presentation/    # UI layer
│           ├── providers/   # Riverpod providers
│           ├── pages/       # Screen widgets
│           └── widgets/     # Feature-specific widgets
└── shared/                  # Cross-cutting concerns
    ├── widgets/             # Reusable UI components
    ├── utils/               # Helper functions
    └── constants/           # App constants
```

### State Management
- **Riverpod** for reactive state management
- Providers for dependency injection
- AsyncNotifier for async operations
- StateNotifier for complex state

### Routing
- **GoRouter** for declarative navigation
- Named routes with type-safe parameters
- Nested navigation support
- Deep linking support

### Networking
- **Dio** with interceptors for:
  - Request/response logging
  - Error handling
  - Authentication token injection
  - Retry logic

## Platform Configuration

### Android
- compileSdk: 34
- minSdk: 24
- targetSdk: 34
- Build flavors: production, tablet

### iOS
- Minimum deployment target: iOS 12.0
- Swift 5.0

### Permissions
- INTERNET
- BLUETOOTH
- ACCESS_FINE_LOCATION
- ACCESS_COARSE_LOCATION
- WAKE_LOCK
- VIBRATION

## Code Quality

### Linting
Strict linting rules enabled via `analysis_options.yaml`:
- All lint rules enabled
- Implicit-casts disabled
- Implicit-dynamic disabled
- Strict raw types enabled

### Code Generation
Required for:
- Freezed immutable classes
- JSON serialization

Run with:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## CI/CD

GitHub Actions workflow:
1. Flutter analyze
2. Flutter test
3. Build debug APK

## Getting Started

```bash
# Install dependencies
flutter pub get

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Build release APK
flutter build apk --release
```
