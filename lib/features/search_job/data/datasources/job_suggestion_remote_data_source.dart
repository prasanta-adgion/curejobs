import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/job_suggestion_model.dart';

abstract interface class JobSuggestionRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<List<JobSuggestionModel>> getSuggestions(String query);
}

class JobSuggestionRemoteDataSourceImpl
    implements JobSuggestionRemoteDataSource {
  const JobSuggestionRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<JobSuggestionModel>> getSuggestions(String query) {
    return _client.get<List<JobSuggestionModel>>(
      ApiEndpoints.jobSearchSuggestions,

      queryParameters: {'field': 'keyword', 'q': query},
      decoder: JobSuggestionModel.listFromJson,
    );
  }
}
