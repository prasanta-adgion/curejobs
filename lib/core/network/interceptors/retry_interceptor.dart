import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

import '../../constants/api_constants.dart';
import '../../error/error_mapper.dart';

/// Retries idempotent requests on transient failures with exponential
/// backoff + jitter. Honors `Retry-After` and cancellation.
///
/// Opt out per request with `Options(extra: {RetryInterceptor.disableRetry: true})`.
class RetryInterceptor extends Interceptor {
  final Dio _dio;

  RetryInterceptor(this._dio);

  static const String disableRetry = 'disableRetry';
  static const String _retryCountKey = '_retryCount';

  static const Set<String> _safeMethods = {'GET', 'HEAD', 'OPTIONS'};
  static const Set<int> _retryStatuses = {408, 429, 500, 502, 503, 504};

  static final Random _random = Random();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final count = (options.extra[_retryCountKey] as int?) ?? 0;

    if (!_shouldRetry(err, count)) {
      return handler.next(err);
    }

    final delay = _delayFor(err, count + 1);

    // Server asked us to wait longer than we are willing to block.
    if (delay == null) {
      return handler.next(err);
    }

    final cancelToken = options.cancelToken;

    await Future.any<void>([
      Future<void>.delayed(delay),
      if (cancelToken != null) cancelToken.whenCancel.then<void>((_) {}),
    ]);

    if (cancelToken?.isCancelled ?? false) {
      return handler.next(err);
    }

    try {
      final response = await _dio.fetch<dynamic>(
        options.copyWith(extra: {...options.extra, _retryCountKey: count + 1}),
      );

      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Duration? _delayFor(DioException err, int attempt) {
    final retryAfter = ErrorMapper.parseRetryAfter(
      err.response?.headers.value('retry-after'),
    );

    if (retryAfter != null) {
      return retryAfter > ApiConstants.maxRetryDelay ? null : retryAfter;
    }

    final backoff = min(
      ApiConstants.initialRetryDelay.inMilliseconds *
          pow(2, attempt - 1).toInt(),
      ApiConstants.maxRetryDelay.inMilliseconds,
    );

    // Jitter avoids synchronized retry bursts across clients.
    return Duration(milliseconds: backoff + _random.nextInt(250));
  }

  bool _shouldRetry(DioException error, int count) {
    final options = error.requestOptions;

    if (count >= ApiConstants.maxRetryAttempts ||
        options.extra[disableRetry] == true ||
        (options.cancelToken?.isCancelled ?? false) ||
        !_safeMethods.contains(options.method.toUpperCase())) {
      return false;
    }

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => true,
      DioExceptionType.badResponse => _retryStatuses.contains(
        error.response?.statusCode,
      ),
      _ => false,
    };
  }
}
