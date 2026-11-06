import '../../../../core/result/result.dart';
import '../../domain/entities/candidate.dart';
import '../../domain/repositories/candidate_repository.dart';
import '../datasources/candidate_remote_data_source.dart';

class CandidateRepositoryImpl implements CandidateRepository {
  final CandidateRemoteDataSource _remote;

  const CandidateRepositoryImpl(this._remote);

  @override
  Future<Result<Candidate>> getMyProfile() {
    return Result.guard(_remote.getMyProfile);
  }

  @override
  Future<Result<String>> getFileAccessUrl({required String fileId}) {
    return Result.guard(() => _remote.getFileAccessUrl(fileId: fileId));
  }
}
