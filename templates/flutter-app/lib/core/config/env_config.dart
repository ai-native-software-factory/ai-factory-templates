/// Environment variables configuration
/// This file loads environment-specific settings
class EnvConfig {
  EnvConfig._();

  /// Load configuration from environment
  static Map<String, String> load() {
    return {
      'FLUTTER_ENV': const String.fromEnvironment('FLUTTER_ENV', defaultValue: 'development'),
      'API_BASE_URL': const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://api.example.com',
      ),
      'ENABLE_LOGGING': const String.fromEnvironment(
        'ENABLE_LOGGING',
        defaultValue: 'true',
      ),
    };
  }

  /// Get environment variable
  static String get(String key, {String? defaultValue}) {
    final env = load();
    return env[key] ?? defaultValue ?? '';
  }

  /// Get boolean environment variable
  static bool getBool(String key, {bool defaultValue = false}) {
    final value = get(key);
    return value.toLowerCase() == 'true' || value == '1' || defaultValue;
  }

  /// Get integer environment variable
  static int getInt(String key, {int defaultValue = 0}) {
    final value = get(key);
    return int.tryParse(value) ?? defaultValue;
  }
}
