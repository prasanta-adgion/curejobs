import '../../../../../../core/result/result.dart';
import '../../domain/entities/education.dart';
import '../../domain/entities/education_params.dart';
import '../../domain/repositories/education_repository.dart';
import '../datasources/education_remote_data_source.dart';

class EducationRepositoryImpl implements EducationRepository {
  final EducationRemoteDataSource _remote;

  const EducationRepositoryImpl(this._remote);

  @override
  Future<Result<List<Education>>> getEducation() {
    return Result.guard(_remote.getEducation);
  }

  @override
  Future<Result<void>> addEducation(EducationParams params) {
    return Result.guard(() => _remote.addEducation(params));
  }

  @override
  Future<Result<void>> updateEducation(String id, EducationParams params) {
    return Result.guard(() => _remote.updateEducation(id, params));
  }

  @override
  Future<Result<void>> deleteEducation(String id) {
    return Result.guard(() => _remote.deleteEducation(id));
  }
}
