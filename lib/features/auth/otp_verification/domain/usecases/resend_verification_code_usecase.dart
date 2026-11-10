import '../../../../../core/result/result.dart';
import '../repositories/email_verification_repository.dart';

/// Asks the server to email a new verification code.
class ResendVerificationCodeUseCase {
  final EmailVerificationRepository _repository;

  const ResendVerificationCodeUseCase(this._repository);

  Future<Result<void>> call({required String email}) {
    return _repository.resendCode(email: email.trim().toLowerCase());
  }
}
