import '../../../../core/result/result.dart';
import '../entities/application_eligibility.dart';
import '../repositories/apply_job_repository.dart';

/// Sends a job application with the chosen CV and screening answers.
class SubmitApplicationUseCase {
  final ApplyJobRepository _repository;

  const SubmitApplicationUseCase(this._repository);

  Future<Result<void>> call({
    required String jobId,
    required String resumeId,
    required List<ScreeningAnswer> answers,
  }) => _repository.submitApplication(
    jobId: jobId,
    resumeId: resumeId,
    answers: answers,
  );
}
