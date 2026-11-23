import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/job_application_status.dart';
import '../models/job_application_status_model.dart';

abstract interface class JobDetailsRemoteDataSource {
  /// Records that the candidate opened a job.
  Future<void> trackJobView({
    required String jobId,
    required String listingContext,
  });

  /// Records that the candidate tapped Apply now.
  Future<void> trackApplyStart({
    required String jobId,
    required String listingContext,
  });

  /// Application status per job id; jobs not applied to are absent.
  Future<Map<String, JobApplicationStatus>> getApplicationStatuses(
    List<String> jobIds,
  );
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

  @override
  Future<void> trackApplyStart({
    required String jobId,
    required String listingContext,
  }) {
    return _client.post<void>(
      ApiEndpoints.applyStartAnalytics(jobId: jobId),
      body: {'listingContext': listingContext},
    );
  }

  @override
  Future<Map<String, JobApplicationStatus>> getApplicationStatuses(
    List<String> jobIds,
  ) {
    return _client.get<Map<String, JobApplicationStatus>>(
      ApiEndpoints.applicationAppliedStatus,
      queryParameters: {'jobIds': jobIds},
      decoder: JobApplicationStatusModel.mapFromJson,
    );
  }
}
