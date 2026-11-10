import '../../../../../../core/result/result.dart';
import '../entities/experience.dart';
import '../repositories/experience_repository.dart';

/// Loads the signed-in candidate's work history.
class GetExperienceUseCase {
  final ExperienceRepository _repository;

  const GetExperienceUseCase(this._repository);

  Future<Result<List<Experience>>> call() => _repository.getExperience();
}
