import '../../../../../../core/result/result.dart';
import '../entities/skill.dart';

/// Contract the domain depends on; the data layer provides the implementation.
abstract interface class SkillRepository {
  Future<Result<List<Skill>>> getSkills();

  Future<Result<void>> addSkill(String name);

  Future<Result<void>> deleteSkill(String id);
}
