import 'environment.dart';

class FlavorConfig {
  final Environment environment;
  final String appName;
  final String baseUrl;
  final bool enableLogging;

  const FlavorConfig({
    required this.environment,
    required this.appName,
    required this.baseUrl,
    required this.enableLogging,
  });

  bool get isDevelopment => environment.isDevelopment;
  bool get isStaging => environment.isStaging;
  bool get isProduction => environment.isProduction;

  factory FlavorConfig.fromEnvironment(Environment environment) {
    switch (environment) {
      case Environment.dev:
        return const FlavorConfig(
          environment: Environment.dev,
          appName: 'CureJobs Dev',
          baseUrl: 'https://api.curejobs.in/',
          enableLogging: true,
        );

      case Environment.staging:
        return const FlavorConfig(
          environment: Environment.staging,
          appName: 'CureJobs Staging',
          baseUrl: 'https://api.curejobs.in/',
          enableLogging: true,
        );

      case Environment.prod:
        return const FlavorConfig(
          environment: Environment.prod,
          appName: 'CureJobs',
          baseUrl: 'https://api.curejobs.in/',
          enableLogging: false,
        );
    }
  }
}
