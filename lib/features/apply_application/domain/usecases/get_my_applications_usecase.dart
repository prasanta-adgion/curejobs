import '../../../../core/result/result.dart';
import '../entities/job_application.dart';
import '../repositories/apply_application_repository.dart';

/// Loads one page of the signed-in candidate's job applications.
class GetMyApplicationsUseCase {
  final ApplyApplicationRepository _repository;

  const GetMyApplicationsUseCase(this._repository);

  /// [status] filters on the server; null returns every status.
  Future<Result<ApplicationsPage>> call({
    int page = 1,
    int limit = 10,
    ApplicationStatus? status,
  }) => _repository.getMyApplications(
    page: page,
    limit: limit,
    status: status,
  );
}
