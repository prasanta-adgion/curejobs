import 'dart:convert';
import 'dart:typed_data';

import 'package:curejobs/core/error/failure.dart';
import 'package:curejobs/core/network/api_client.dart';
import 'package:curejobs/core/network/dio_api_client.dart';
import 'package:curejobs/core/network/interceptors/retry_interceptor.dart';
import 'package:curejobs/core/result/result.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Replies with queued responses and records every request.
class _FakeAdapter implements HttpClientAdapter {
  final List<(int, Object?)> replies;
  final List<RequestOptions> requests = [];

  _FakeAdapter(this.replies);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final (status, body) = replies.removeAt(0);

    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _User {
  final int id;
  final String name;

  const _User(this.id, this.name);

  factory _User.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return _User(map['id'] as int, map['name'] as String);
  }
}

(ApiClient, _FakeAdapter) _client(List<(int, Object?)> replies) {
  final adapter = _FakeAdapter(replies);
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test/'))
    ..httpClientAdapter = adapter;
  return (DioApiClient(dio), adapter);
}

void main() {
  test('decodes a successful response', () async {
    final (api, adapter) = _client([
      (200, {'id': 1, 'name': 'Asha'}),
    ]);

    final user = await api.get('users/1', decoder: _User.fromJson);

    expect(user.name, 'Asha');
    expect(adapter.requests.single.method, 'GET');
  });

  test('sends query parameters on every method', () async {
    final (api, adapter) = _client([(200, null)]);

    await api.post<Object?>(
      'jobs',
      body: {'a': 1},
      queryParameters: {'q': 'x'},
    );

    expect(adapter.requests.single.uri.queryParameters, {'q': 'x'});
    expect(adapter.requests.single.method, 'POST');
  });

  test('wrong response shape becomes ParsingFailure', () async {
    final (api, _) = _client([
      (200, ['not', 'a', 'map']),
    ]);

    await expectLater(
      api.get('users/1', decoder: _User.fromJson),
      throwsA(isA<ParsingFailure>()),
    );
  });

  test('HTTP errors become typed failures, never DioException', () async {
    final (api, _) = _client([
      (
        422,
        {
          'message': 'Nope',
          'errors': {
            'email': ['Taken'],
          },
        },
      ),
    ]);

    await expectLater(
      api.post<Object?>('users'),
      throwsA(
        isA<ValidationFailure>()
            .having((f) => f.message, 'message', 'Nope')
            .having((f) => f.errorFor('email'), 'email', 'Taken'),
      ),
    );
  });

  test('Result.guard captures failures', () async {
    final (api, _) = _client([(404, null)]);

    final result = await Result.guard(
      () => api.get('users/9', decoder: _User.fromJson),
    );

    expect(result.isOk, isFalse);
    expect(result.failureOrNull, isA<NotFoundFailure>());
  });

  test('retries safe requests on 503 and succeeds', () async {
    final adapter = _FakeAdapter([
      (503, null),
      (200, {'id': 2, 'name': 'Ravi'}),
    ]);
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(RetryInterceptor(dio));

    final user = await DioApiClient(dio)
        .get('users/2', decoder: _User.fromJson);

    expect(user.id, 2);
    expect(adapter.requests, hasLength(2));
  });

  test('does not retry non-idempotent requests', () async {
    final adapter = _FakeAdapter([(503, null), (200, null)]);
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(RetryInterceptor(dio));

    await expectLater(
      DioApiClient(dio).post<Object?>('jobs'),
      throwsA(isA<ServerFailure>()),
    );
    expect(adapter.requests, hasLength(1));
  });
}
