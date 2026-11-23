import '../../../../core/result/result.dart';
import '../entities/job_application_status.dart';

abstract interface class JobDetailsRepository {
  Future<Result<void>> trackJobView({
    required String jobId,
    required String listingContext,
  });

  Future<Result<void>> trackApplyStart({
    required String jobId,
    required String listingContext,
  });

  Future<Result<Map<String, JobApplicationStatus>>> getApplicationStatuses(
    List<String> jobIds,
  );
}
