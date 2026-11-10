import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/create_account_request_model.dart';

abstract interface class CreateAccountRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<void> createAccount(CreateAccountRequestModel request);
}

class CreateAccountRemoteDataSourceImpl
    implements CreateAccountRemoteDataSource {
  final ApiClient _client;

  const CreateAccountRemoteDataSourceImpl(this._client);

  @override
  Future<void> createAccount(CreateAccountRequestModel request) {
    return _client.put<void>(
      ApiEndpoints.candidateProfile,
      body: request.toJson(),
    );
  }
}
