import '../../../../../../core/result/result.dart';
import '../repositories/skill_repository.dart';

/// Removes one skill by id.
class DeleteSkillUseCase {
  final SkillRepository _repository;

  const DeleteSkillUseCase(this._repository);

  Future<Result<void>> call(String id) => _repository.deleteSkill(id);
}
