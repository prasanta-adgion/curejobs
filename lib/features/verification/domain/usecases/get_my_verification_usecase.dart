import '../../../../core/result/result.dart';
import '../entities/candidate_verification.dart';
import '../repositories/verification_repository.dart';

/// Loads the user's own verification (`GET verifications/me`): whether a
/// request has been started, document status and badge.
class GetMyVerificationUseCase {
  final VerificationRepository _repository;

  const GetMyVerificationUseCase(this._repository);

  Future<Result<CandidateVerification>> call() =>
      _repository.getMyVerification();
}
