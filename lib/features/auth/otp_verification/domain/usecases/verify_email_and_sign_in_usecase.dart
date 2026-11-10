import '../../../../../core/error/failure.dart';
import '../../../../../core/result/result.dart';
import '../../../login/domain/entities/auth_user.dart';
import '../../../login/domain/usecases/login_usecase.dart';
import 'verify_email_usecase.dart';

/// What happened after a correct code.
sealed class EmailVerificationOutcome {
  const EmailVerificationOutcome();
}

/// Verified and signed in; the session is stored.
final class VerifiedAndSignedIn extends EmailVerificationOutcome {
  final AuthUser user;

  const VerifiedAndSignedIn(this.user);
}

/// Verified, but the automatic sign-in failed (for example offline). The
/// account is ready; the user signs in manually.
final class VerifiedSignInRequired extends EmailVerificationOutcome {
  final Failure signInFailure;

  const VerifiedSignInRequired(this.signInFailure);
}

/// Verifies the email, then signs in with the credentials just used to
/// register, because the verify endpoint does not start a session.
class VerifyEmailAndSignInUseCase {
  final VerifyEmailUseCase _verifyEmail;
  final LoginUseCase _login;

  const VerifyEmailAndSignInUseCase(this._verifyEmail, this._login);

  /// Fails only when verification itself fails (wrong or expired code).
  Future<Result<EmailVerificationOutcome>> call({
    required String email,
    required String password,
    required String code,
  }) async {
    final verified = await _verifyEmail(email: email, code: code);
    if (verified case Err(:final failure)) return Result.err(failure);

    final signedIn = await _login(email: email, password: password);
    return Result.ok(
      signedIn.fold<EmailVerificationOutcome>(
        VerifiedAndSignedIn.new,
        VerifiedSignInRequired.new,
      ),
    );
  }
}
