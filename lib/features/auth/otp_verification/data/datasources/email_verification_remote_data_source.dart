import 'package:dio/dio.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/interceptors/session_interceptor.dart';

abstract interface class EmailVerificationRemoteDataSource {
  /// Marks the email as verified. Does not sign the user in: the server
  /// returns no session cookie here.
  ///
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<void> verifyEmail({required String email, required String code});

  /// Throws a `Failure` on error (see [ApiClient]).
  Future<void> resendCode({required String email});
}

class EmailVerificationRemoteDataSourceImpl
    implements EmailVerificationRemoteDataSource {
  final ApiClient _client;

  const EmailVerificationRemoteDataSourceImpl(this._client);

  /// The user is not signed in yet, so no session cookie is sent.
  static final _publicOptions = Options(
    extra: {SessionInterceptor.skipAuth: true},
  );

  @override
  Future<void> verifyEmail({required String email, required String code}) {
    print('verifyEmail called with email: $email, code: $code');
    return _client.post<void>(
      ApiEndpoints.verifyOtp,
      body: {'email': email, 'otp': code},
      decoder: (_) {},
      options: _publicOptions,
    );
  }

  @override
  Future<void> resendCode({required String email}) {
    return _client.post<void>(
      ApiEndpoints.resendVerificationCode,
      body: {'email': email},
      decoder: (_) {},
      options: _publicOptions,
    );
  }
}
