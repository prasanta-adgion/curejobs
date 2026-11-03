import '../../../../core/result/result.dart';
import '../entities/candidate.dart';
import '../repositories/candidate_repository.dart';

/// Loads the signed-in candidate's profile.
class GetCandidateProfileUseCase {
  final CandidateRepository _repository;

  const GetCandidateProfileUseCase(this._repository);

  Future<Result<Candidate>> call() => _repository.getMyProfile();
}
