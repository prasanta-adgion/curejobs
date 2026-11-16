import '../../../../../../core/result/result.dart';
import '../repositories/resume_repository.dart';

/// Permanently deletes a resume.
class DeleteResumeUseCase {
  final ResumeRepository _repository;

  const DeleteResumeUseCase(this._repository);

  Future<Result<void>> call(String resumeId) =>
      _repository.deleteResume(resumeId: resumeId);
}
