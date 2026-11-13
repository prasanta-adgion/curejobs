import '../../../../core/result/result.dart';
import '../repositories/job_details_repository.dart';

/// Where the job was opened from, sent as `listingContext`.
abstract final class JobListingContext {
  static const splitDetail = 'jobs_split_detail';
}

/// Sends a job view to analytics. Failures are returned, never thrown.
class TrackJobViewUseCase {
  final JobDetailsRepository _repository;

  const TrackJobViewUseCase(this._repository);

  Future<Result<void>> call(
    String jobId, {
    String listingContext = JobListingContext.splitDetail,
  }) => _repository.trackJobView(jobId: jobId, listingContext: listingContext);
}
