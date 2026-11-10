import '../../../../../core/result/result.dart';

abstract interface class EmailVerificationRepository {
  /// Confirms [email] with the one-time [code] sent to it.
  Future<Result<void>> verifyEmail({
    required String email,
    required String code,
  });

  /// Sends a fresh code to [email].
  Future<Result<void>> resendCode({required String email});
}
