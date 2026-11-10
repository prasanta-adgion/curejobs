import '../../../../../../core/result/result.dart';
import '../../domain/entities/education.dart';
import '../../domain/repositories/education_repository.dart';
import '../datasources/education_remote_data_source.dart';

class EducationRepositoryImpl implements EducationRepository {
  final EducationRemoteDataSource _remote;

  const EducationRepositoryImpl(this._remote);

  @override
  Future<Result<List<Education>>> getEducation() {
    return Result.guard(_remote.getEducation);
  }
}
