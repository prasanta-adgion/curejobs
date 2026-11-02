import 'dart:developer' as developer;

typedef ErrorReportHandler = void Function(
  Object error,
  StackTrace? stackTrace, {
  bool fatal,
});

/// Single sink for unexpected errors. Plug Crashlytics / Sentry in by
/// setting [handler] during bootstrap; nothing else needs to change.
final class ErrorReporter {
  ErrorReporter._();

  static ErrorReportHandler? handler;

  static void report(
    Object error,
    StackTrace? stackTrace, {
    bool fatal = false,
    String? reason,
  }) {
    developer.log(
      reason ?? (fatal ? 'Fatal error' : 'Unexpected error'),
      name: 'curejobs.error',
      error: error,
      stackTrace: stackTrace,
      level: fatal ? 1200 : 1000,
    );

    handler?.call(error, stackTrace, fatal: fatal);
  }
}
