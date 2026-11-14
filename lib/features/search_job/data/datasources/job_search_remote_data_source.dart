import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../all_jobs/data/models/job_page_model.dart';
import '../../domain/entities/search_query.dart';

abstract interface class JobSearchRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<JobPageModel> search({
    required SearchQuery query,
    required int page,
    required int limit,
  });
}

class JobSearchRemoteDataSourceImpl implements JobSearchRemoteDataSource {
  final ApiClient _client;

  const JobSearchRemoteDataSourceImpl(this._client);

  /// `GET api/v1/jobs` with every filter set on [query] (see
  /// [SearchQuery.toQueryParameters]); unset ones are left out.
  @override
  Future<JobPageModel> search({
    required SearchQuery query,
    required int page,
    required int limit,
  }) {
    return _client.get<JobPageModel>(
      ApiEndpoints.jobs,
      queryParameters: {
        ...query.toQueryParameters(),
        'page': page,
        'limit': limit,
      },
      decoder: JobPageModel.fromJson,
    );
  }
}
