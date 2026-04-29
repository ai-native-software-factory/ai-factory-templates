/// Environment configuration
enum Environment {
  development('development'),
  staging('staging'),
  production('production'),
  profile('profile');

  const Environment(this.value);
  final String value;

  static Environment fromString(String? value) {
    return Environment.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Environment.development,
    );
  }

  bool get isDevelopment => this == Environment.development;
  bool get isStaging => this == Environment.staging;
  bool get isProduction => this == Environment.production;
  bool get isProfile => this == Environment.profile;
}

/// Environment-specific configuration
class AppEnvConfig {
  final Environment environment;
  final String apiBaseUrl;
  final bool enableLogging;
  final bool enableDebugTools;
  final String appName;

  const AppEnvConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableLogging,
    required this.enableDebugTools,
    required this.appName,
  });

  factory AppEnvConfig.development() {
    return const AppEnvConfig(
      environment: Environment.development,
      apiBaseUrl: 'https://dev-api.example.com',
      enableLogging: true,
      enableDebugTools: true,
      appName: 'Flutter App Dev',
    );
  }

  factory AppEnvConfig.staging() {
    return const AppEnvConfig(
      environment: Environment.staging,
      apiBaseUrl: 'https://staging-api.example.com',
      enableLogging: true,
      enableDebugTools: true,
      appName: 'Flutter App Staging',
    );
  }

  factory AppEnvConfig.production() {
    return const AppEnvConfig(
      environment: Environment.production,
      apiBaseUrl: 'https://api.example.com',
      enableLogging: false,
      enableDebugTools: false,
      appName: 'Flutter App',
    );
  }

  factory AppEnvConfig.profile() {
    return const AppEnvConfig(
      environment: Environment.profile,
      apiBaseUrl: 'https://api.example.com',
      enableLogging: true,
      enableDebugTools: true,
      appName: 'Flutter App Profile',
    );
  }

  factory AppEnvConfig.fromEnvironment(Environment env) {
    switch (env) {
      case Environment.development:
        return AppEnvConfig.development();
      case Environment.staging:
        return AppEnvConfig.staging();
      case Environment.production:
        return AppEnvConfig.production();
      case Environment.profile:
        return AppEnvConfig.profile();
    }
  }
}
