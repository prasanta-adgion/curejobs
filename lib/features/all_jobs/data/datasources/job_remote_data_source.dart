import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/job_feed.dart';
import '../models/job_page_model.dart';

abstract interface class JobRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<JobPageModel> getJobs({
    required JobFeed feed,
    required int page,
    required int limit,
  });
}

class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  final ApiClient _client;

  const JobRemoteDataSourceImpl(this._client);

  @override
  Future<JobPageModel> getJobs({
    required JobFeed feed,
    required int page,
    required int limit,
  }) {
    final path = switch (feed) {
      JobFeed.all => ApiEndpoints.jobs,
      JobFeed.recommended => ApiEndpoints.jobsRecommended,
    };
    return _client.get<JobPageModel>(
      path,
      queryParameters: {'page': page, 'limit': limit},
      decoder: JobPageModel.fromJson,
    );
  }
}
