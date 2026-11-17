import '../../../../../../core/result/result.dart';
import '../repositories/resume_repository.dart';

/// Saves an uploaded file as a new CV.
class CreateResumeUseCase {
  final ResumeRepository _repository;

  const CreateResumeUseCase(this._repository);

  Future<Result<void>> call({
    required String title,
    required String fileId,
    required bool isDefault,
  }) => _repository.createResume(
    title: title,
    fileId: fileId,
    isDefault: isDefault,
  );
}
