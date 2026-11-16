import '../../../../../../core/result/result.dart';
import '../repositories/resume_repository.dart';

/// Resolves a resume's generated file id to a short-lived signed URL.
class GetResumeFileUrlUseCase {
  final ResumeRepository _repository;

  const GetResumeFileUrlUseCase(this._repository);

  Future<Result<String>> call(String fileId) =>
      _repository.getFileAccessUrl(fileId: fileId);
}
