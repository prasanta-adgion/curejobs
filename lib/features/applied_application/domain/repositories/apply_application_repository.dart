import '../../../../core/result/result.dart';
import '../entities/job_application.dart';

abstract interface class ApplyApplicationRepository {
  /// [status] filters on the server; null returns every status.
  Future<Result<ApplicationsPage>> getMyApplications({
    required int page,
    required int limit,
    ApplicationStatus? status,
  });

  Future<Result<void>> withdrawApplication(String id);
}
