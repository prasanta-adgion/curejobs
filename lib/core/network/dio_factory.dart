import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'interceptors/session_interceptor.dart';
import 'session_manager.dart';

class DioFactory {
  DioFactory._();

  static BaseOptions _baseOptions(String baseUrl) {
    return BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      responseType: ResponseType.json,
      headers: {
        ApiConstants.acceptHeader: ApiConstants.applicationJson,
        ApiConstants.contentTypeHeader: ApiConstants.applicationJson,
      },
    );
  }

  /// Client for presigned S3 uploads. It must never carry the session cookie,
  /// and has no logging because the URL itself grants access.
  static Dio createS3Dio() {
    return Dio(
      BaseOptions(
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.uploadSendTimeout,
      ),
    );
  }

  /// Bare client used only by [SessionManager] to refresh the session.
  /// It has no session interceptor, so a refresh can never trigger
  /// another refresh.
  static Dio createRefreshDio({
    required String baseUrl,
    required bool enableLogging,
    bool logBodies = false,
  }) {
    final dio = Dio(_baseOptions(baseUrl));

    if (enableLogging) {
      dio.interceptors.add(LoggingInterceptor(logBodies: logBodies));
    }

    return dio;
  }

  /// Main client used by the app.
  ///
  /// Interceptor order matters:
  /// 1. Session attaches the cookie and handles 401 refresh first.
  /// 2. Retry handles transient network / 5xx failures.
  /// 3. Logging sees the final request and outcome.
  static Dio createApiDio({
    required String baseUrl,
    required bool enableLogging,
    bool logBodies = false,
    required SessionManager sessionManager,
  }) {
    final dio = Dio(_baseOptions(baseUrl));

    dio.interceptors.addAll([
      SessionInterceptor(
        dio: dio,
        sessionManager: sessionManager,
        trustedBaseUrl: baseUrl,
      ),
      RetryInterceptor(dio),
      if (enableLogging) LoggingInterceptor(logBodies: logBodies),
    ]);

    return dio;
  }
}
