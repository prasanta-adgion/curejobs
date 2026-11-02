import 'package:equatable/equatable.dart';

/// Every error that leaves the data layer is a [Failure].
///
/// [message] is always safe to show to the user. Use the subtype (or
/// [isRetryable]) to decide what the UI should offer.
sealed class Failure extends Equatable implements Exception {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  /// Whether trying the same action again can reasonably succeed.
  bool get isRetryable => false;

  @override
  List<Object?> get props => [runtimeType, message, statusCode];

  @override
  String toString() => '$runtimeType($statusCode): $message';
}

final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Please check your internet connection.',
  ]);

  @override
  bool get isRetryable => true;
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure([
    super.message = 'The request timed out. Please try again.',
  ]);

  @override
  bool get isRetryable => true;
}

/// The session is gone; the user must sign in again.
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Your session has expired. Please sign in again.',
  ]) : super(statusCode: 401);
}

/// The session could not be restored right now, but may be later.
final class SessionRecoveryFailure extends Failure {
  const SessionRecoveryFailure([
    super.message = 'Unable to restore your session. Please try again.',
  ]);

  @override
  bool get isRetryable => true;
}

final class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'You do not have permission.'])
    : super(statusCode: 403);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([
    super.message = 'The requested resource was not found.',
  ]) : super(statusCode: 404);
}

final class ValidationFailure extends Failure {
  /// Field name -> messages, as returned by the backend.
  final Map<String, List<String>> fieldErrors;

  const ValidationFailure({
    String message = 'Please check the submitted information.',
    int? statusCode,
    this.fieldErrors = const {},
  }) : super(message, statusCode: statusCode);

  String? errorFor(String field) {
    final errors = fieldErrors[field];
    return errors == null || errors.isEmpty ? null : errors.first;
  }

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

final class ConflictFailure extends Failure {
  const ConflictFailure([super.message = 'This conflicts with existing data.'])
    : super(statusCode: 409);
}

final class RateLimitFailure extends Failure {
  final Duration? retryAfter;

  const RateLimitFailure({
    String message = 'Too many requests. Please wait a moment.',
    this.retryAfter,
  }) : super(message, statusCode: 429);

  @override
  bool get isRetryable => true;

  @override
  List<Object?> get props => [...super.props, retryAfter];
}

final class ServerFailure extends Failure {
  const ServerFailure({
    String message = 'Server error. Please try again later.',
    super.statusCode,
  }) : super(message);

  @override
  bool get isRetryable => true;
}

final class CancelledFailure extends Failure {
  const CancelledFailure() : super('Request cancelled.');
}

/// The server answered, but not in the shape the app expects.
final class ParsingFailure extends Failure {
  const ParsingFailure([
    super.message = 'Invalid response received from server.',
  ]);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something unexpected happened.']);

  @override
  bool get isRetryable => true;
}
