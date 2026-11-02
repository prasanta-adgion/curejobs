import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

import '../../constants/api_constants.dart';

class RetryInterceptor extends Interceptor {
  final Dio _dio;

  RetryInterceptor(this._dio);

  static const String _retryCountKey = '_retryCount';

  static const Set<String> _safeMethods = {'GET', 'HEAD', 'OPTIONS'};

  static const Set<int> _retryStatuses = {408, 429, 500, 502, 503, 504};

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;

    final count = (options.extra[_retryCountKey] as int?) ?? 0;

    if (!_shouldRetry(err, count)) {
      return handler.next(err);
    }

    final nextCount = count + 1;

    final baseDelay = min(500 * pow(2, nextCount - 1).toInt(), 4000);

    // Add a small randomized delay to avoid bursts.
    final delay = Duration(milliseconds: baseDelay + Random().nextInt(250));

    try {
      await Future.any<void>([
        Future<void>.delayed(delay),
        if (options.cancelToken != null)
          options.cancelToken!.whenCancel.then<void>((_) {}),
      ]);

      if (options.cancelToken?.isCancelled ?? false) {
        return handler.next(err);
      }

      final retryOptions = options.copyWith(
        extra: {...options.extra, _retryCountKey: nextCount},
      );

      final response = await _dio.fetch<dynamic>(retryOptions);

      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _shouldRetry(DioException error, int count) {
    if (count >= ApiConstants.maxRetryAttempts) {
      return false;
    }

    final options = error.requestOptions;

    if (options.extra['disableRetry'] == true) {
      return false;
    }

    if (options.cancelToken?.isCancelled ?? false) {
      return false;
    }

    if (!_safeMethods.contains(options.method.toUpperCase())) {
      return false;
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError) {
      return true;
    }

    return _retryStatuses.contains(error.response?.statusCode);
  }
}
