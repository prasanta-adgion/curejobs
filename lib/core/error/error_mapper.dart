import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../network/session_signals.dart';
import 'api_error_body.dart';
import 'failure.dart';

/// Turns any thrown object into a [Failure]. This is the single place
/// where error classification happens.
final class ErrorMapper {
  ErrorMapper._();

  static Failure map(Object error) {
    return switch (error) {
      Failure() => error,
      DioException() => _fromDio(error),
      SocketException() || HttpException() => const NetworkFailure(),
      HandshakeException() || TlsException() => const NetworkFailure(
        'Secure connection failed. Please try again.',
      ),
      TimeoutException() => const TimeoutFailure(),
      // Thrown while decoding a response into a model.
      FormatException() || TypeError() => const ParsingFailure(),
      _ => const UnknownFailure(),
    };
  }

  static Failure _fromDio(DioException error) {
    final inner = error.error;

    if (inner is SessionExpiredSignal) {
      return const UnauthorizedFailure();
    }

    if (inner is SessionRecoverySignal) {
      return SessionRecoveryFailure(
        error.message ?? const SessionRecoveryFailure().message,
      );
    }

    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const TimeoutFailure(),
      DioExceptionType.connectionError => const NetworkFailure(),
      DioExceptionType.badCertificate => const NetworkFailure(
        'Secure connection failed. Please try again.',
      ),
      DioExceptionType.cancel => const CancelledFailure(),
      DioExceptionType.badResponse => _fromResponse(error.response),
      // Errors thrown inside interceptors / transformers land here.
      DioExceptionType.unknown || DioExceptionType.transformTimeout =>
        inner == null ? const UnknownFailure() : map(inner),
    };
  }

  static Failure _fromResponse(Response<dynamic>? response) {
    final code = response?.statusCode;
    final body = ApiErrorBody.parse(response?.data);
    final message = body.message;

    return switch (code) {
      400 || 422 => ValidationFailure(
        message: message ?? const ValidationFailure().message,
        statusCode: code,
        fieldErrors: body.fieldErrors,
      ),
      401 => UnauthorizedFailure(
        message ?? const UnauthorizedFailure().message,
      ),
      403 => ForbiddenFailure(message ?? const ForbiddenFailure().message),
      404 => NotFoundFailure(message ?? const NotFoundFailure().message),
      408 => const TimeoutFailure(),
      409 => ConflictFailure(message ?? const ConflictFailure().message),
      429 => RateLimitFailure(
        message: message ?? const RateLimitFailure().message,
        retryAfter: parseRetryAfter(response?.headers.value('retry-after')),
      ),
      504 => const TimeoutFailure(),
      final int c when c >= 500 => ServerFailure(statusCode: c),
      _ => UnknownFailure(message ?? const UnknownFailure().message),
    };
  }

  /// Supports both the delta-seconds and HTTP-date forms.
  static Duration? parseRetryAfter(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final seconds = int.tryParse(value.trim());

    if (seconds != null) {
      return seconds < 0 ? null : Duration(seconds: seconds);
    }

    try {
      final date = HttpDate.parse(value);
      final delta = date.difference(DateTime.now().toUtc());
      return delta.isNegative ? Duration.zero : delta;
    } on Exception {
      // HttpDate.parse throws HttpException on malformed input.
      return null;
    }
  }
}
