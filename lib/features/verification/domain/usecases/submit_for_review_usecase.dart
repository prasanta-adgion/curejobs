import '../../../../core/result/result.dart';
import '../entities/verification_request_detail.dart';
import '../repositories/verification_repository.dart';

/// Sends a verification request for admin review
/// (`POST verifications/{id}/submit`).
class SubmitForReviewUseCase {
  final VerificationRepository _repository;

  const SubmitForReviewUseCase(this._repository);

  Future<Result<VerificationRequestDetail>> call({
    required String verificationId,
  }) => _repository.submitForReview(verificationId: verificationId);
}
