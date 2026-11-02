import 'package:dio/dio.dart';

abstract interface class ApiClient {
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<T> post<T>(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<T> put<T>(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<T> patch<T>(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<T> delete<T>(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  });
}
