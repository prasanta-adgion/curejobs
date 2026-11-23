import '../../../../core/result/result.dart';
import '../entities/verification_eligibility.dart';
import '../repositories/verification_repository.dart';

/// Loads where the user is in verification: documents, review, badge.
class GetVerificationEligibilityUseCase {
  final VerificationRepository _repository;

  const GetVerificationEligibilityUseCase(this._repository);

  Future<Result<VerificationEligibility>> call() =>
      _repository.getEligibility();
}
