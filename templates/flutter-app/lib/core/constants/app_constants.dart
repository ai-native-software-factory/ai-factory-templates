/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Flutter App';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // API
  static const int apiVersion = 1;
  static const String apiPrefix = '/api/v$apiVersion';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache
  static const Duration cacheDuration = Duration(minutes: 5);
  static const Duration longCacheDuration = Duration(hours: 1);

  // Animation
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // UI
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double iconSize = 24.0;
  static const double iconSizeLarge = 32.0;

  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
}
