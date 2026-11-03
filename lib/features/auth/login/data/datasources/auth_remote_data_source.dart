import 'package:dio/dio.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/interceptors/session_interceptor.dart';
import '../models/auth_user_model.dart';

abstract interface class AuthRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<AuthUserModel> login({
    required String email,
    required String password,
  });

  /// Throws a `Failure` on error (see [ApiClient]).
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _client;

  const AuthRemoteDataSourceImpl(this._client);

  @override
  Future<AuthUserModel> login({
    required String email,
    required String password,
  }) {
    return _client.post<AuthUserModel>(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
      decoder: AuthUserModel.fromJson,
      // The session interceptor stores the returned session cookie.
      options: Options(
        extra: {
          SessionInterceptor.skipAuth: true,
          SessionInterceptor.captureSession: true,
        },
      ),
    );
  }

  @override
  Future<void> logout() async {
    // The session interceptor attaches the current session cookie.
    await _client.post<void>(ApiEndpoints.logout, decoder: (_) {});
  }
}
