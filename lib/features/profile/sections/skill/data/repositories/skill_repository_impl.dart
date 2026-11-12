import '../../../../../../core/result/result.dart';
import '../../domain/entities/skill.dart';
import '../../domain/repositories/skill_repository.dart';
import '../datasources/skill_remote_data_source.dart';

class SkillRepositoryImpl implements SkillRepository {
  final SkillRemoteDataSource _remote;

  const SkillRepositoryImpl(this._remote);

  @override
  Future<Result<List<Skill>>> getSkills() => Result.guard(_remote.getSkills);

  @override
  Future<Result<void>> addSkill(String name) {
    return Result.guard(() => _remote.addSkill(name));
  }

  @override
  Future<Result<void>> deleteSkill(String id) {
    return Result.guard(() => _remote.deleteSkill(id));
  }
}
