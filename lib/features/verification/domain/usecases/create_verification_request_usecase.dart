import '../../../../core/result/result.dart';
import '../entities/verification_eligibility.dart';
import '../repositories/verification_repository.dart';

/// Starts a verification request (`POST verifications`); documents are then
/// attached to its id.
class CreateVerificationRequestUseCase {
  final VerificationRepository _repository;

  const CreateVerificationRequestUseCase(this._repository);

  Future<Result<VerificationRequest>> call() => _repository.createRequest();
}
