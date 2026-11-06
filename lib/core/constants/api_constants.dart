class ApiConstants {
  ApiConstants._();

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  static const Duration uploadSendTimeout = Duration(minutes: 2);

  // Headers
  static const String contentTypeHeader = 'Content-Type';
  static const String acceptHeader = 'Accept';
  static const String cookieHeader = 'Cookie';

  static const String applicationJson = 'application/json';

  //session-related
  static const String cookieName = 'cj_session';
  static const String setCookieHeader = 'set-cookie';

  // Retry configuration
  static const int maxRetryAttempts = 3;

  static const Duration initialRetryDelay = Duration(milliseconds: 500);

  static const Duration maxRetryDelay = Duration(seconds: 5);
}
