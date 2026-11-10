import 'package:dio/dio.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/interceptors/session_interceptor.dart';
import '../models/registration_result_model.dart';

abstract interface class RegistrationRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<RegistrationResultModel> register({
    required String email,
    required String password,
  });
}

class RegistrationRemoteDataSourceImpl implements RegistrationRemoteDataSource {
  /// The app only signs up candidates.
  static const String candidateRole = 'CANDIDATE';

  final ApiClient _client;

  const RegistrationRemoteDataSourceImpl(this._client);

  @override
  Future<RegistrationResultModel> register({
    required String email,
    required String password,
  }) {
    return _client.post<RegistrationResultModel>(
      ApiEndpoints.register,
      body: {'role': candidateRole, 'email': email, 'password': password},
      decoder: RegistrationResultModel.fromJson,
      options: Options(extra: {SessionInterceptor.skipAuth: true}),
    );
  }
}
