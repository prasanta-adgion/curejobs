import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/json_parser.dart';
import '../models/candidate_model.dart';

abstract interface class CandidateRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<CandidateModel> getMyProfile();

  /// Returns a short-lived signed URL for the file.
  Future<String> getFileAccessUrl({required String fileId});

  Future<void> updateProfile({required CandidateModel candidate});
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

  @override
  Future<String> getFileAccessUrl({required String fileId}) {
    return _client.get<String>(
      ApiEndpoints.getFileAccess(fileId: fileId),
      decoder: (json) {
        final data = JsonParser.map(JsonParser.map(json)['data']);
        final url = JsonParser.string(data['accessUrl']);
        if (url.isEmpty) {
          throw const FormatException('Invalid file access response');
        }
        return url;
      },
    );
  }

  @override
  Future<void> updateProfile({required CandidateModel candidate}) {
    return _client.put(ApiEndpoints.candidateProfile, body: candidate.toJson());
  }
}
