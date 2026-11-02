import 'package:dio/dio.dart';

import '../../constants/api_constants.dart';

import '../session_cookie_parser.dart';
import '../session_manager.dart';
import '../session_signals.dart';
import 'retry_interceptor.dart';

class SessionInterceptor extends Interceptor {
  final Dio _dio;
  final SessionManager _sessionManager;

  final Uri _trustedBaseUri;

  SessionInterceptor({
    required Dio dio,
    required SessionManager sessionManager,
    required String trustedBaseUrl,
  }) : _dio = dio,
       _sessionManager = sessionManager,
       _trustedBaseUri = Uri.parse(trustedBaseUrl);

  static const skipAuth = 'skipAuth';
  static const captureSession = 'captureSession';
  static const retriedAfterRefresh = 'retriedAfterRefresh';
  static const allowReauthReplay = 'allowReauthReplay';

  static const _generationKey = '_authGeneration';

  // --------------------------------------------------
  // REQUEST
  // --------------------------------------------------

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      if (!_trusted(options.uri)) {
        return handler.reject(
          DioException(
            requestOptions: options,
            message: 'Untrusted API destination',
          ),
        );
      }

      if (options.extra[skipAuth] == true) {
        options.headers.remove(ApiConstants.cookieHeader);

        options.extra[_generationKey] = _sessionManager.generation;

        return handler.next(options);
      }

      final session = await _sessionManager.getSession();

      if (session == null || session.isEmpty) {
        options.headers.remove(ApiConstants.cookieHeader);
      } else {
        options.headers[ApiConstants.cookieHeader] =
            '${ApiConstants.cookieName}=$session';
      }

      options.extra[_generationKey] = _sessionManager.generation;

      handler.next(options);
    } catch (error, stackTrace) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stackTrace,
          message: 'Unable to prepare request',
        ),
      );
    }
  }

  // --------------------------------------------------
  // RESPONSE
  // --------------------------------------------------

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final options = response.requestOptions;

    if (options.extra[captureSession] != true) {
      return handler.next(response);
    }

    try {
      final cookie = SessionCookieParser.parse(response.headers);

      if (cookie == null || SessionCookieParser.isExpired(cookie)) {
        return handler.reject(
          DioException(
            requestOptions: options,
            response: response,
            message: 'Valid session cookie not returned',
          ),
        );
      }

      final expectedGeneration = options.extra[_generationKey] as int?;

      if (expectedGeneration == null) {
        return handler.reject(
          DioException(
            requestOptions: options,
            message: 'Missing authentication generation',
          ),
        );
      }

      final saved = await _sessionManager.saveLoginIfCurrent(
        cookie.value,
        expectedGeneration,
      );

      if (!saved) {
        return handler.reject(
          DioException(
            requestOptions: options,
            message: 'Login was superseded',
          ),
        );
      }

      handler.next(response);
    } catch (error, stackTrace) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stackTrace,
          message: 'Unable to save session',
        ),
      );
    }
  }

  // --------------------------------------------------
  // ERROR — AUTOMATIC 401 REFRESH
  // --------------------------------------------------

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) async {
    final options = error.requestOptions;

    if (error.response?.statusCode != 401 ||
        options.extra[skipAuth] == true ||
        options.extra[retriedAfterRefresh] == true) {
      return handler.next(error);
    }

    try {
      final originalGeneration = options.extra[_generationKey] as int?;

      if (originalGeneration == null ||
          originalGeneration != _sessionManager.generation) {
        return handler.next(
          _sessionError(error, 'Session changed during request'),
        );
      }

      final currentSession = await _sessionManager.getSession();

      if (currentSession == null || currentSession.isEmpty) {
        return handler.next(_sessionError(error, 'Session expired'));
      }

      final expectedCookie = '${ApiConstants.cookieName}=$currentSession';

      final sentCookie = options.headers[ApiConstants.cookieHeader];

      // Another request may have already refreshed
      // the session before this 401 was handled.
      if (sentCookie != expectedCookie) {
        return await _handleReplay(error, handler, currentSession);
      }

      final refreshStatus = await _sessionManager.refresh();

      switch (refreshStatus) {
        case RefreshStatus.success:
          final renewedSession = await _sessionManager.getSession();

          if (renewedSession == null || renewedSession.isEmpty) {
            return handler.next(_sessionError(error, 'Session expired'));
          }

          return await _handleReplay(error, handler, renewedSession);

        case RefreshStatus.expired:
          return handler.next(_sessionError(error, 'Session expired'));

        case RefreshStatus.temporaryFailure:
          return handler.next(
            _sessionError(
              error,
              'Session refresh temporarily unavailable',
              temporary: true,
            ),
          );

        case RefreshStatus.superseded:
          return handler.next(
            _sessionError(error, 'Authentication state changed'),
          );
      }
    } on DioException catch (retryError) {
      return handler.next(retryError);
    } catch (unexpectedError, stackTrace) {
      return handler.next(
        DioException(
          requestOptions: options,
          error: unexpectedError,
          stackTrace: stackTrace,
          message: 'Session recovery failed',
        ),
      );
    }
  }

  Future<void> _handleReplay(
    DioException originalError,
    ErrorInterceptorHandler handler,
    String session,
  ) async {
    final options = originalError.requestOptions;

    // Automatically replay only safe HTTP methods.
    // Other methods need explicit backend-approved opt-in.
    final method = options.method.toUpperCase();

    final safeMethod =
        method == 'GET' || method == 'HEAD' || method == 'OPTIONS';

    if (!safeMethod && options.extra[allowReauthReplay] != true) {
      return handler.next(
        _sessionError(
          originalError,
          'Session renewed. Retry the action.',
          temporary: true,
        ),
      );
    }

    // Multipart and streaming request bodies may not be
    // safely reusable after they have been finalized.
    if (options.data is FormData || options.data is Stream) {
      return handler.next(
        _sessionError(
          originalError,
          'Request must be recreated after refresh',
          temporary: true,
        ),
      );
    }

    try {
      final retryOptions = options.copyWith(
        headers: {
          ...options.headers,
          ApiConstants.cookieHeader: '${ApiConstants.cookieName}=$session',
        },
        extra: {
          ...options.extra,
          retriedAfterRefresh: true,
          RetryInterceptor.disableRetry: true,
        },
      );

      final response = await _dio.fetch<dynamic>(retryOptions);

      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  DioException _sessionError(
    DioException original,
    String message, {
    bool temporary = false,
  }) {
    return DioException(
      requestOptions: original.requestOptions,
      response: original.response,
      type: DioExceptionType.unknown,
      message: message,
      error: temporary
          ? const SessionRecoverySignal()
          : const SessionExpiredSignal(),
    );
  }

  bool _trusted(Uri uri) {
    final trustedPort = _trustedBaseUri.hasPort
        ? _trustedBaseUri.port
        : (_trustedBaseUri.scheme == 'https' ? 443 : 80);

    return uri.scheme == _trustedBaseUri.scheme &&
        uri.host == _trustedBaseUri.host &&
        uri.port == trustedPort;
  }
}
