import 'package:dio/dio.dart';

import '../error/app_exception.dart';
import '../error/error_mapper.dart';

import 'api_client.dart';

class DioApiClient implements ApiClient {
  final Dio _dio;

  const DioApiClient(this._dio);

  Future<T> _execute<T>({
    required Future<Response<T>> Function() request,
  }) async {
    try {
      final response = await request();
      final data = response.data;

      if (data == null) {
        if (null is T) {
          return data as T;
        }

        throw const UnexpectedResponseException();
      }

      return data;
    } on DioException catch (error) {
      throw ErrorMapper.map(error);
    }
  }

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _execute<T>(
      request: () => _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  @override
  Future<T> post<T>(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _execute<T>(
      request: () => _dio.post<T>(
        path,
        data: data,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  @override
  Future<T> put<T>(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _execute<T>(
      request: () => _dio.put<T>(
        path,
        data: data,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  @override
  Future<T> patch<T>(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _execute<T>(
      request: () => _dio.patch<T>(
        path,
        data: data,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }

  @override
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _execute<T>(
      request: () => _dio.delete<T>(
        path,
        data: data,
        options: options,
        cancelToken: cancelToken,
      ),
    );
  }
}
