import 'package:flutter/material.dart';

/// Application-wide configuration constants
class AppConfig {
  AppConfig._();

  /// Application name
  static const String appName = 'Flutter App';

  /// Current environment
  static String get env => AppEnv.env;

  /// Whether running in debug mode
  static bool get isDebug => AppEnv.env == 'development';

  /// Whether running in release mode
  static bool get isRelease = !isDebug && !isProfile;

  /// Whether running in profile mode
  static bool get isProfile = AppEnv.env == 'profile';

  /// Whether running on tablet
  static bool get isTablet =>
      (ScreenSize.width >= 600 || ScreenSize.height >= 600);

  /// Screen design size for flutter_screenutil
  static const Size screenDesignSize = Size(375, 812);

  /// Primary brand color
  static const Color primaryColor = Color(0xFF2196F3);

  /// Secondary brand color
  static const Color secondaryColor = Color(0xFF03A9F4);

  /// Error color
  static const Color errorColor = Color(0xFFE53935);

  /// Success color
  static const Color successColor = Color(0xFF4CAF50);

  /// Warning color
  static const Color warningColor = Color(0xFFFFC107);

  /// API base URL
  static String get apiBaseUrl {
    switch (AppEnv.env) {
      case 'production':
        return 'https://api.example.com';
      case 'staging':
        return 'https://staging-api.example.com';
      case 'development':
      default:
        return 'https://dev-api.example.com';
    }
  }

  /// API timeout duration
  static const Duration apiTimeout = Duration(seconds: 30);

  /// Pagination page size
  static const int defaultPageSize = 20;

  /// Maximum retry attempts for network requests
  static const int maxRetries = 3;

  /// Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);
}

/// Screen size helper
class ScreenSize {
  ScreenSize._();

  static double _width = 0;
  static double _height = 0;

  static double get width => _width;
  static double get height => _height;

  static void initialize(BuildContext? context) {
    if (context != null) {
      _width = MediaQuery.of(context).size.width;
      _height = MediaQuery.of(context).size.height;
    }
  }
}

/// Environment enum
class AppEnv {
  AppEnv._();

  /// Current environment name
  static String get env {
    // Check for environment override from system
    const envFromSystem = String.fromEnvironment('FLUTTER_ENV');
    if (envFromSystem.isNotEmpty) return envFromSystem;

    // Default to development
    return 'development';
  }
}
