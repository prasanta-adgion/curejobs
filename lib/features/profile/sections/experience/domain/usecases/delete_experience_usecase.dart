import '../../../../../../core/result/result.dart';
import '../repositories/experience_repository.dart';

/// Removes a position from the candidate's work history.
class DeleteExperienceUseCase {
  final ExperienceRepository _repository;

  const DeleteExperienceUseCase(this._repository);

  Future<Result<void>> call(String id) => _repository.deleteExperience(id);
}
