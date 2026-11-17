import '../../../../core/result/result.dart';
import '../repositories/job_details_repository.dart';
import 'track_job_view_usecase.dart';

/// Sends "Apply now tapped" to analytics. Failures are returned, never thrown.
class TrackApplyStartUseCase {
  final JobDetailsRepository _repository;

  const TrackApplyStartUseCase(this._repository);

  Future<Result<void>> call(
    String jobId, {
    String listingContext = JobListingContext.jobDetail,
  }) =>
      _repository.trackApplyStart(jobId: jobId, listingContext: listingContext);
}
