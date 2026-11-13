import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/job_page_model.dart';

abstract interface class JobRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<JobPageModel> getJobs({required int page, required int limit});
}

class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  final ApiClient _client;

  const JobRemoteDataSourceImpl(this._client);

  @override
  Future<JobPageModel> getJobs({required int page, required int limit}) {
    return _client.get<JobPageModel>(
      ApiEndpoints.jobsRecommended,
      queryParameters: {'page': page, 'limit': limit},
      decoder: JobPageModel.fromJson,
    );
  }
}
