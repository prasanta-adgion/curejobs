import 'flavor_config.dart';

class AppConfig {
  AppConfig._();

  static FlavorConfig? _config;

  static void initialize(FlavorConfig config) {
    if (_config != null) {
      throw StateError('AppConfig already initialized');
    }

    _config = config;
  }

  static FlavorConfig get current {
    final config = _config;

    if (config == null) {
      throw StateError('AppConfig not initialized');
    }

    return config;
  }

  static String get baseUrl => current.baseUrl;

  static String get appName => current.appName;

  static bool get enableLogging => current.enableLogging;

  static bool get isProduction => current.isProduction;
}
