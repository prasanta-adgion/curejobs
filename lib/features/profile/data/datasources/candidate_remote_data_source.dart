import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/candidate_model.dart';

abstract interface class CandidateRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<CandidateModel> getMyProfile();
}

class CandidateRemoteDataSourceImpl implements CandidateRemoteDataSource {
  final ApiClient _client;

  const CandidateRemoteDataSourceImpl(this._client);

  @override
  Future<CandidateModel> getMyProfile() {
    return _client.get<CandidateModel>(
      ApiEndpoints.candidateProfile,
      decoder: CandidateModel.fromJson,
    );
  }
}
