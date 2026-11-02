import '../error/error_mapper.dart';
import '../error/error_reporter.dart';
import '../error/failure.dart';

/// Outcome of an operation that can fail. Repositories return this so
/// callers handle failures explicitly instead of catching exceptions.
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;
  const factory Result.err(Failure failure) = Err<T>;

  /// Runs [body] and converts anything it throws into an [Err].
  ///
  /// Failures that point to a bug (parsing / unknown) are reported.
  static Future<Result<T>> guard<T>(Future<T> Function() body) async {
    try {
      return Ok(await body());
    } catch (error, stackTrace) {
      final failure = ErrorMapper.map(error);

      if (failure is ParsingFailure || failure is UnknownFailure) {
        ErrorReporter.report(error, stackTrace, reason: failure.message);
      }

      return Err(failure);
    }
  }

  bool get isOk => this is Ok<T>;

  T? get valueOrNull => switch (this) {
    Ok(:final value) => value,
    Err() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Ok() => null,
    Err(:final failure) => failure,
  };

  R fold<R>(R Function(T value) onOk, R Function(Failure failure) onErr) {
    return switch (this) {
      Ok(:final value) => onOk(value),
      Err(:final failure) => onErr(failure),
    };
  }

  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Ok(:final value) => Ok(transform(value)),
      Err(:final failure) => Err(failure),
    };
  }
}

final class Ok<T> extends Result<T> {
  final T value;

  const Ok(this.value);
}

final class Err<T> extends Result<T> {
  final Failure failure;

  const Err(this.failure);
}
