import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// Logs requests with timing. Session cookies are always redacted;
/// bodies are logged only when [logBodies] is true (dev builds).
class LoggingInterceptor extends Interceptor {
  final bool logBodies;

  const LoggingInterceptor({this.logBodies = false});

  static const String _name = 'curejobs.network';
  static const String _startKey = '_logStartedAt';
  static const int _maxBodyLength = 2000;

  static const Set<String> _sensitiveHeaders = {
    'cookie',
    'set-cookie',
    'authorization',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = DateTime.now().microsecondsSinceEpoch;

    developer.log(
      '--> ${options.method} ${options.uri}'
      '${logBodies ? '\nheaders: ${_redact(options.headers)}${_body(options.data)}' : ''}',
      name: _name,
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;

    developer.log(
      '<-- ${response.statusCode} ${options.method} ${options.uri} '
      '(${_elapsed(options)})'
      '${logBodies ? _body(response.data) : ''}',
      name: _name,
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final status = err.response?.statusCode;

    developer.log(
      '<-- ${status ?? err.type.name} ${options.method} ${options.uri} '
      '(${_elapsed(options)}): ${err.message ?? err.type.name}'
      '${logBodies ? _body(err.response?.data) : ''}',
      name: _name,
      level: 900,
    );

    handler.next(err);
  }

  String _elapsed(RequestOptions options) {
    final start = options.extra[_startKey] as int?;

    if (start == null) {
      return '?ms';
    }

    final micros = DateTime.now().microsecondsSinceEpoch - start;
    return '${micros ~/ 1000}ms';
  }

  static Map<String, Object?> _redact(Map<String, dynamic> headers) {
    return {
      for (final entry in headers.entries)
        entry.key: _sensitiveHeaders.contains(entry.key.toLowerCase())
            ? '<redacted>'
            : entry.value,
    };
  }

  static String _body(Object? data) {
    if (data == null || data is FormData || data is Stream) {
      return '';
    }

    final text = data.toString();

    return text.length > _maxBodyLength
        ? '\nbody: ${text.substring(0, _maxBodyLength)}…'
        : '\nbody: $text';
  }
}
