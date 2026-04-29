/// Storage keys for SharedPreferences
class StorageKeys {
  StorageKeys._();

  // Auth keys
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';

  // App settings
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String onboardingComplete = 'onboarding_complete';

  // App state
  static const String lastSyncTime = 'last_sync_time';
  static const String cachedUser = 'cached_user';

  // Feature-specific
  static const String exampleCache = 'example_cache';
}
