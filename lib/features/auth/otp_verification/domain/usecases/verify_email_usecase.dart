import '../../../../../core/result/result.dart';
import '../repositories/email_verification_repository.dart';

/// Confirms the user's email with the code they received.
class VerifyEmailUseCase {
  final EmailVerificationRepository _repository;

  const VerifyEmailUseCase(this._repository);

  Future<Result<void>> call({required String email, required String code}) {
    return _repository.verifyEmail(
      email: email.trim().toLowerCase(),
      code: code.trim(),
    );
  }
}
