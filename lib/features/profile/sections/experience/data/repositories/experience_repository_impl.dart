import '../../../../../../core/result/result.dart';
import '../../domain/entities/experience.dart';
import '../../domain/entities/experience_params.dart';
import '../../domain/repositories/experience_repository.dart';
import '../datasources/experience_remote_data_source.dart';

class ExperienceRepositoryImpl implements ExperienceRepository {
  final ExperienceRemoteDataSource _remote;

  const ExperienceRepositoryImpl(this._remote);

  @override
  Future<Result<List<Experience>>> getExperience() {
    return Result.guard(_remote.getExperience);
  }

  @override
  Future<Result<void>> addExperience(ExperienceParams params) {
    return Result.guard(() => _remote.addExperience(params));
  }

  @override
  Future<Result<void>> updateExperience(String id, ExperienceParams params) {
    return Result.guard(() => _remote.updateExperience(id, params));
  }

  @override
  Future<Result<void>> deleteExperience(String id) {
    return Result.guard(() => _remote.deleteExperience(id));
  }
}
