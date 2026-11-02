import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../constants/api_constants.dart';

class LoggingInterceptor extends Interceptor {
  const LoggingInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      '${options.method} ${options.uri}',
      name: 'curejobs.network',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      '${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri}',
      name: 'curejobs.network',
    );
    handler.next(response);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    final cookie = error.requestOptions.headers[ApiConstants.cookieHeader];
    final detail = cookie == null ? '' : ' (session cookie redacted)';

    developer.log(
      '${error.requestOptions.method} ${error.requestOptions.uri}: '
      '${error.message ?? error.type.name}$detail',
      name: 'curejobs.network',
      error: error,
    );
    handler.next(error);
  }
}
