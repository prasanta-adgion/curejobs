import 'dart:io';

import 'package:curejobs/core/error/error_mapper.dart';
import 'package:curejobs/core/error/failure.dart';
import 'package:curejobs/core/network/session_signals.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

final _options = RequestOptions(path: '/x');

DioException _type(DioExceptionType type, {Object? error}) =>
    DioException(requestOptions: _options, type: type, error: error);

DioException _status(
  int code, {
  Object? data,
  Map<String, List<String>> headers = const {},
}) {
  return DioException.badResponse(
    statusCode: code,
    requestOptions: _options,
    response: Response<Object?>(
      requestOptions: _options,
      statusCode: code,
      data: data,
      headers: Headers.fromMap(headers),
    ),
  );
}

void main() {
  group('Dio error types', () {
    test('timeouts', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(ErrorMapper.map(_type(type)), isA<TimeoutFailure>());
      }
    });

    test('connection error / cancel / certificate', () {
      expect(
        ErrorMapper.map(_type(DioExceptionType.connectionError)),
        isA<NetworkFailure>(),
      );
      expect(
        ErrorMapper.map(_type(DioExceptionType.cancel)),
        isA<CancelledFailure>(),
      );
      expect(
        ErrorMapper.map(_type(DioExceptionType.badCertificate)),
        isA<NetworkFailure>(),
      );
    });

    test('unknown unwraps the inner error', () {
      expect(
        ErrorMapper.map(
          _type(DioExceptionType.unknown, error: const SocketException('x')),
        ),
        isA<NetworkFailure>(),
      );
      expect(
        ErrorMapper.map(_type(DioExceptionType.unknown)),
        isA<UnknownFailure>(),
      );
    });

    test('session signals', () {
      expect(
        ErrorMapper.map(
          _type(DioExceptionType.unknown, error: const SessionExpiredSignal()),
        ),
        isA<UnauthorizedFailure>(),
      );
      expect(
        ErrorMapper.map(
          _type(DioExceptionType.unknown, error: const SessionRecoverySignal()),
        ),
        isA<SessionRecoveryFailure>(),
      );
    });
  });

  group('HTTP status', () {
    test('maps each status to its failure', () {
      expect(ErrorMapper.map(_status(401)), isA<UnauthorizedFailure>());
      expect(ErrorMapper.map(_status(403)), isA<ForbiddenFailure>());
      expect(ErrorMapper.map(_status(404)), isA<NotFoundFailure>());
      expect(ErrorMapper.map(_status(408)), isA<TimeoutFailure>());
      expect(ErrorMapper.map(_status(409)), isA<ConflictFailure>());
      expect(ErrorMapper.map(_status(504)), isA<TimeoutFailure>());
      expect(ErrorMapper.map(_status(418)), isA<UnknownFailure>());

      final server = ErrorMapper.map(_status(503));
      expect(server, isA<ServerFailure>());
      expect(server.statusCode, 503);
    });

    test('validation reads message and field errors', () {
      final failure = ErrorMapper.map(
        _status(
          422,
          data: {
            'message': 'Invalid input',
            'errors': {
              'email': ['Email is taken'],
              'name': 'Required',
            },
          },
        ),
      );

      expect(failure, isA<ValidationFailure>());
      failure as ValidationFailure;
      expect(failure.message, 'Invalid input');
      expect(failure.errorFor('email'), 'Email is taken');
      expect(failure.errorFor('name'), 'Required');
      expect(failure.errorFor('phone'), isNull);
    });

    test('validation accepts list-shaped errors', () {
      final failure = ErrorMapper.map(
        _status(
          400,
          data: {
            'errors': [
              {'field': 'email', 'message': 'Bad email'},
            ],
          },
        ),
      ) as ValidationFailure;

      expect(failure.errorFor('email'), 'Bad email');
      expect(failure.message, const ValidationFailure().message);
    });

    test('uses server message when present', () {
      expect(
        ErrorMapper.map(_status(403, data: {'error': 'Account locked'}))
            .message,
        'Account locked',
      );
    });

    test('ignores non-JSON error bodies', () {
      expect(
        ErrorMapper.map(_status(404, data: '<html>')).message,
        const NotFoundFailure().message,
      );
    });

    test('429 reads Retry-After', () {
      final failure = ErrorMapper.map(
        _status(
          429,
          headers: {
            'retry-after': ['7'],
          },
        ),
      ) as RateLimitFailure;

      expect(failure.retryAfter, const Duration(seconds: 7));
      expect(failure.isRetryable, isTrue);
    });
  });

  group('non-Dio errors', () {
    test('parsing errors', () {
      expect(
        ErrorMapper.map(const FormatException('bad')),
        isA<ParsingFailure>(),
      );

      Object? typeError;
      try {
        (Object() as String).length;
      } catch (e) {
        typeError = e;
      }
      expect(ErrorMapper.map(typeError!), isA<ParsingFailure>());
    });

    test('failures pass through, anything else is unknown', () {
      const failure = NotFoundFailure();
      expect(identical(ErrorMapper.map(failure), failure), isTrue);
      expect(ErrorMapper.map(StateError('x')), isA<UnknownFailure>());
    });
  });

  test('parseRetryAfter', () {
    expect(ErrorMapper.parseRetryAfter(null), isNull);
    expect(ErrorMapper.parseRetryAfter('abc'), isNull);
    expect(ErrorMapper.parseRetryAfter('-1'), isNull);
    expect(ErrorMapper.parseRetryAfter('3'), const Duration(seconds: 3));
    expect(
      ErrorMapper.parseRetryAfter('Wed, 21 Oct 2015 07:28:00 GMT'),
      Duration.zero,
    );
  });
}
