import '../../../../../../core/result/result.dart';
import '../entities/skill.dart';
import '../repositories/skill_repository.dart';

/// Loads the signed-in candidate's skills.
class GetSkillsUseCase {
  final SkillRepository _repository;

  const GetSkillsUseCase(this._repository);

  Future<Result<List<Skill>>> call() => _repository.getSkills();
}
