import '../../../../../../core/result/result.dart';
import '../repositories/resume_repository.dart';

/// Makes a resume the one sent with applications. The server clears the
/// previous default.
class SetDefaultResumeUseCase {
  final ResumeRepository _repository;

  const SetDefaultResumeUseCase(this._repository);

  Future<Result<void>> call(String resumeId) =>
      _repository.setDefault(resumeId: resumeId);
}
