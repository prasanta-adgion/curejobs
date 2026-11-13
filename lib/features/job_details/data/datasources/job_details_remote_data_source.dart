import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

abstract interface class JobDetailsRemoteDataSource {
  /// Records that the candidate opened a job.
  Future<void> trackJobView({
    required String jobId,
    required String listingContext,
  });
}

class JobDetailsRemoteDataSourceImpl implements JobDetailsRemoteDataSource {
  final ApiClient _client;

  const JobDetailsRemoteDataSourceImpl(this._client);

  @override
  Future<void> trackJobView({
    required String jobId,
    required String listingContext,
  }) {
    return _client.post<void>(
      ApiEndpoints.jobViewAnalytics(id: jobId),
      body: {'listingContext': listingContext},
    );
  }
}
