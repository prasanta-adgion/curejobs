/// Internal markers attached to [DioException.error] by the session
/// interceptor so [ErrorMapper] can tell session problems apart from
/// a plain 401 coming from the server.
final class SessionExpiredSignal {
  const SessionExpiredSignal();
}

final class SessionRecoverySignal {
  const SessionRecoverySignal();
}
