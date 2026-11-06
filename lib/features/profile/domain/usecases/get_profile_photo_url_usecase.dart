import '../../../../core/result/result.dart';
import '../repositories/candidate_repository.dart';

/// Resolves a profile photo's file id to a short-lived signed URL.
class GetProfilePhotoUrlUseCase {
  final CandidateRepository _repository;

  const GetProfilePhotoUrlUseCase(this._repository);

  Future<Result<String>> call(String fileId) {
    return _repository.getFileAccessUrl(fileId: fileId);
  }
}
