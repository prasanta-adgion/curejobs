enum Environment {
  dev,
  staging,
  prod;

  bool get isDevelopment => this == Environment.dev;
  bool get isStaging => this == Environment.staging;
  bool get isProduction => this == Environment.prod;
}
