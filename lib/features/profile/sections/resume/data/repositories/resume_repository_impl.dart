import '../../../../../../core/result/result.dart';
import '../../domain/entities/resume.dart';
import '../../domain/repositories/resume_repository.dart';
import '../datasources/resume_remote_data_source.dart';

class ResumeRepositoryImpl implements ResumeRepository {
  final ResumeRemoteDataSource _remote;

  const ResumeRepositoryImpl(this._remote);

  @override
  Future<Result<List<Resume>>> getResumes() => Result.guard(_remote.getResumes);

  @override
  Future<Result<void>> setDefault({required String resumeId}) {
    return Result.guard(() => _remote.setDefault(resumeId: resumeId));
  }

  @override
  Future<Result<void>> deleteResume({required String resumeId}) {
    return Result.guard(() => _remote.deleteResume(resumeId: resumeId));
  }
}
