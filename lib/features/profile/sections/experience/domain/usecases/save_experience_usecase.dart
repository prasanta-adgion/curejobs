import '../../../../../../core/result/result.dart';
import '../entities/experience_params.dart';
import '../repositories/experience_repository.dart';

/// Adds a new position, or updates one when [id] is given.
class SaveExperienceUseCase {
  final ExperienceRepository _repository;

  const SaveExperienceUseCase(this._repository);

  Future<Result<void>> call(ExperienceParams params, {String? id}) {
    return id == null
        ? _repository.addExperience(params)
        : _repository.updateExperience(id, params);
  }
}
