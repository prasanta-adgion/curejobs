import '../../../../core/result/result.dart';
import '../entities/application_eligibility.dart';
import '../repositories/apply_job_repository.dart';

/// Checks whether the candidate can apply and loads screening questions.
class GetApplicationEligibilityUseCase {
  final ApplyJobRepository _repository;

  const GetApplicationEligibilityUseCase(this._repository);

  Future<Result<ApplicationEligibility>> call(String jobId) =>
      _repository.getEligibility(jobId);
}
