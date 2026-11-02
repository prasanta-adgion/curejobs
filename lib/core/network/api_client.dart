import 'package:dio/dio.dart';

/// Converts the raw decoded JSON body into a typed value.
typedef JsonDecoder<T> = T Function(Object? json);

enum HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  patch('PATCH'),
  delete('DELETE');

  const HttpMethod(this.value);

  final String value;
}

/// Transport abstraction used by data sources.
///
/// Every method either returns the decoded value or throws a `Failure`
/// (see `core/error/failure.dart`); it never leaks [DioException].
/// Wrap calls in `Result.guard` at the repository boundary.
///
/// Without a [JsonDecoder] the body is returned as-is and must already
/// be a `T` (use `Object?` / `void` when the body is irrelevant).
abstract interface class ApiClient {
  Future<T> request<T>(
    HttpMethod method,
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    JsonDecoder<T>? decoder,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    JsonDecoder<T>? decoder,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    JsonDecoder<T>? decoder,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    JsonDecoder<T>? decoder,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    JsonDecoder<T>? decoder,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<T> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    JsonDecoder<T>? decoder,
    Options? options,
    CancelToken? cancelToken,
  });

  /// Multipart upload. Not replayed automatically after a session
  /// refresh, so callers should rebuild [formData] on retry.
  Future<T> upload<T>(
    String path, {
    required FormData Function() formData,
    JsonDecoder<T>? decoder,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  });

  Future<void> download(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  });
}
