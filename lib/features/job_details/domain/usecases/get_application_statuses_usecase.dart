import '../../../../core/result/result.dart';
import '../entities/job_application_status.dart';
import '../repositories/job_details_repository.dart';

/// The candidate's application status for each of [jobIds], keyed by job
/// id. Jobs the candidate hasn't applied to are absent from the map.
class GetApplicationStatusesUseCase {
  final JobDetailsRepository _repository;

  const GetApplicationStatusesUseCase(this._repository);

  Future<Result<Map<String, JobApplicationStatus>>> call(List<String> jobIds) =>
      _repository.getApplicationStatuses(jobIds);

  /// Convenience for a single job; null when not applied.
  Future<Result<JobApplicationStatus?>> forJob(String jobId) async =>
      (await call([jobId])).map((m) => m[jobId]);
}
