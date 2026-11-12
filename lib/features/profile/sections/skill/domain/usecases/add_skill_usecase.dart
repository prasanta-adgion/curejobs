import '../../../../../../core/result/result.dart';
import '../repositories/skill_repository.dart';

/// Adds one skill by name.
class AddSkillUseCase {
  final SkillRepository _repository;

  const AddSkillUseCase(this._repository);

  Future<Result<void>> call(String name) => _repository.addSkill(name.trim());
}
