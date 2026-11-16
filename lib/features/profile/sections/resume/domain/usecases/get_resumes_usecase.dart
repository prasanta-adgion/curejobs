import '../../../../../../core/result/result.dart';
import '../entities/resume.dart';
import '../repositories/resume_repository.dart';

/// Loads the candidate's resumes.
class GetResumesUseCase {
  final ResumeRepository _repository;

  const GetResumesUseCase(this._repository);

  Future<Result<List<Resume>>> call() => _repository.getResumes();
}
