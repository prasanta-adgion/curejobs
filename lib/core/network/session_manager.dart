import 'dart:async';

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/session_storage.dart';

import 'api_endpoints.dart';
import 'session_cookie_parser.dart';

enum RefreshStatus { success, expired, temporaryFailure, superseded }

class SessionManager {
  final SessionStorageInterface _storage;
  final Dio _refreshDio;

  SessionManager({required this._storage, required this._refreshDio});

  Future<RefreshStatus>? _refreshInProgress;

  // Increment when login/logout changes authentication.
  int _generation = 0;

  final StreamController<bool> _authChanges =
      StreamController<bool>.broadcast();

  Stream<bool> get authChanges => _authChanges.stream;

  int get generation => _generation;

  Future<String?> getSession() => _storage.getSession();

  // Future<bool> hasSession() async {
  //   final session = await getSession();
  //   return session != null && session.isNotEmpty;
  // }

  /// Used after a successful login.
  Future<void> saveLoginSession(String sessionId) async {
    _generation++;

    await _storage.saveSession(sessionId: sessionId);

    _authChanges.add(true);
  }

  /// Returns true only when this generation still owns
  /// the authentication state.
  Future<bool> saveLoginIfCurrent(
    String sessionId,
    int expectedGeneration,
  ) async {
    if (_generation != expectedGeneration) {
      return false;
    }

    await saveLoginSession(sessionId);
    return true;
  }

  /// Clear the local session and invalidate pending
  /// refresh results.
  Future<void> logoutLocal() async {
    _generation++;

    await _storage.clearSession();

    _authChanges.add(false);
  }

  /// Only clear if the failed session still belongs to
  /// the current authentication generation.
  Future<void> expireIfCurrent(
    String expectedSession,
    int expectedGeneration,
  ) async {
    if (_generation != expectedGeneration) return;

    final current = await _storage.getSession();

    if (current != expectedSession) return;

    await logoutLocal();
  }

  /// All simultaneous 401 requests share one refresh.
  Future<RefreshStatus> refresh() {
    final existing = _refreshInProgress;

    if (existing != null) {
      return existing;
    }

    final completer = Completer<RefreshStatus>();

    _refreshInProgress = completer.future;

    () async {
      try {
        final result = await _refresh();
        completer.complete(result);
      } catch (_) {
        completer.complete(RefreshStatus.temporaryFailure);
      } finally {
        _refreshInProgress = null;
      }
    }();

    return completer.future;
  }

  Future<RefreshStatus> _refresh() async {
    final expectedGeneration = _generation;

    final oldSession = await _storage.getSession();

    if (oldSession == null || oldSession.isEmpty) {
      return RefreshStatus.expired;
    }

    try {
      final response = await _refreshDio.post<dynamic>(
        ApiEndpoints.refresh,
        options: Options(
          headers: {
            ApiConstants.cookieHeader: '${ApiConstants.cookieName}=$oldSession',
          },
          followRedirects: false,
        ),
      );

      if (_generation != expectedGeneration) {
        return RefreshStatus.superseded;
      }

      final cookie = SessionCookieParser.parse(response.headers);

      // Backend contract assumption:
      // successful refresh sends a renewed cookie.
      if (cookie == null || SessionCookieParser.isExpired(cookie)) {
        return RefreshStatus.temporaryFailure;
      }

      final currentSession = await _storage.getSession();

      if (currentSession != oldSession) {
        return RefreshStatus.superseded;
      }

      await _storage.saveSession(sessionId: cookie.value);

      return RefreshStatus.success;
    } on DioException catch (error) {
      if (_generation != expectedGeneration) {
        return RefreshStatus.superseded;
      }

      final statusCode = error.response?.statusCode;

      if (statusCode == 401 || statusCode == 403) {
        await expireIfCurrent(oldSession, expectedGeneration);

        return RefreshStatus.expired;
      }

      return RefreshStatus.temporaryFailure;
    }
  }

  Future<void> dispose() async {
    await _authChanges.close();
  }
}
