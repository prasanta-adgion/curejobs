import 'package:dio/dio.dart';

import '../error/error_mapper.dart';
import '../error/failure.dart';
import 'api_client.dart';

final class DioApiClient implements ApiClient {
  final Dio _dio;

  const DioApiClient(this._dio);

  @override
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
  }) async {
    final Response<Object?> response;

    try {
      response = await _dio.request<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(method: method.value),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (error) {
      throw ErrorMapper.map(error);
    }

    return _decode(response.data, decoder);
  }

  T _decode<T>(Object? body, JsonDecoder<T>? decoder) {
    try {
      if (decoder != null) {
        return decoder(body);
      }

      return body as T;
    } on Failure {
      rethrow;
    } catch (_) {
      // TypeError / FormatException from a model's fromJson.
      throw const ParsingFailure();
    }
  }

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    JsonDecoder<T>? decoder,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return request<T>(
      HttpMethod.get,
      path,
      queryParameters: queryParameters,
      decoder: decoder,
      options: options,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<T> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    JsonDecoder<T>? decoder,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return request<T>(
      HttpMethod.post,
      path,
      data: body,
      queryParameters: queryParameters,
      decoder: decoder,
      options: options,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<T> put<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    JsonDecoder<T>? decoder,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return request<T>(
      HttpMethod.put,
      path,
      data: body,
      queryParameters: queryParameters,
      decoder: decoder,
      options: options,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<T> patch<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    JsonDecoder<T>? decoder,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return request<T>(
      HttpMethod.patch,
      path,
      data: body,
      queryParameters: queryParameters,
      decoder: decoder,
      options: options,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<T> delete<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    JsonDecoder<T>? decoder,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return request<T>(
      HttpMethod.delete,
      path,
      data: body,
      queryParameters: queryParameters,
      decoder: decoder,
      options: options,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<T> upload<T>(
    String path, {
    required FormData Function() formData,
    JsonDecoder<T>? decoder,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) {
    return request<T>(
      HttpMethod.post,
      path,
      data: formData(),
      decoder: decoder,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
  }

  @override
  Future<void> download(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
        deleteOnError: true,
      );
    } catch (error) {
      throw ErrorMapper.map(error);
    }
  }
}
