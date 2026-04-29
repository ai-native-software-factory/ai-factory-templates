# Flutter App Template

A production-ready Flutter application template using modern Flutter 3.x architecture patterns.

## Features

- **Clean Architecture**: Feature-based clean architecture with data, domain, and presentation layers
- **State Management**: Riverpod for reactive state management
- **Navigation**: GoRouter for declarative routing
- **Networking**: Dio with interceptors for API calls
- **Code Generation**: Freezed for immutable data classes, json_serializable for JSON serialization
- **Responsive UI**: flutter_screenutil for responsive design
- **Local Storage**: SharedPreferences and path_provider for data persistence
- **Permissions**: permission_handler for runtime permissions
- **Media**: audioplayers and lottie for audio and animations
- **Web**: webview_flutter for web content

## Project Structure

```
lib/
├── core/                    # Shared infrastructure
│   ├── config/              # App configuration
│   ├── network/             # Dio HTTP client, interceptors
│   ├── storage/             # Local storage abstractions
│   ├── router/              # GoRouter configuration
│   └── constants/           # App constants
├── features/                # Feature modules
│   └── example/             # Example feature
│       ├── data/            # Data layer
│       ├── domain/          # Business logic layer
│       └── presentation/    # UI layer
└── shared/                  # Cross-cutting concerns
    ├── widgets/             # Reusable UI components
    ├── utils/               # Helper functions
    └── constants/           # Shared constants
```

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate code:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. Run the app:
   ```bash
   flutter run
   ```

### Building

**Debug APK:**
```bash
flutter build apk --debug
```

**Release APK:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios
```

## Architecture

### Clean Architecture Layers

1. **Presentation Layer**: UI widgets, pages, and Riverpod providers
2. **Domain Layer**: Business entities, repository interfaces, and use cases
3. **Data Layer**: Repository implementations, data sources, and models

### State Management

We use Riverpod with the following patterns:
- `FutureProvider` for async data
- `AsyncNotifierProvider` for complex async state
- `Provider` for dependency injection

### Routing

GoRouter provides declarative navigation with:
- Named routes
- Type-safe parameters
- Nested navigation
- Deep linking support

### Networking

Dio is configured with:
- Request/response logging interceptor
- Error handling interceptor
- Retry interceptor for failed requests
- Authentication token injection

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## CI/CD

GitHub Actions workflow:
- Flutter analyze
- Flutter test
- Build debug APK

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

MIT License
