import 'package:dio/dio.dart';

import 'app_exception.dart';
import 'failure.dart';

class ErrorMapper {
  ErrorMapper._();

  static AppException map(DioException error) {
    if (error.error is SessionExpiredFailure) {
      return const SessionExpiredException();
    }

    if (error.error is SessionRecoveryFailure) {
      return const SessionRecoveryException();
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const RequestTimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.cancel:
        return const RequestCancelledException();

      case DioExceptionType.badCertificate:
        return const NetworkException();

      case DioExceptionType.badResponse:
        return _mapStatus(error.response?.statusCode);

      case DioExceptionType.unknown:
      case DioExceptionType.transformTimeout:
        return const UnknownException();
    }
  }

  static AppException _mapStatus(int? code) {
    switch (code) {
      case 400:
      case 422:
        return ValidationException(statusCode: code);

      case 401:
        return const SessionExpiredException();

      case 403:
        return const ForbiddenException();

      case 404:
        return const NotFoundException();

      case 408:
      case 504:
        return const RequestTimeoutException();

      default:
        if (code != null && code >= 500) {
          return ServerException(statusCode: code);
        }

        return const UnknownException();
    }
  }
}
