import 'package:curejobs/core/error/failure.dart';
import 'package:curejobs/core/result/result.dart';
import 'package:curejobs/features/auth/login/domain/entities/auth_user.dart';
import 'package:curejobs/features/auth/login/domain/repositories/auth_repository.dart';
import 'package:curejobs/features/auth/login/domain/usecases/login_usecase.dart';
import 'package:curejobs/features/auth/otp_verification/domain/repositories/email_verification_repository.dart';
import 'package:curejobs/features/auth/otp_verification/domain/usecases/verify_email_and_sign_in_usecase.dart';
import 'package:curejobs/features/auth/otp_verification/domain/usecases/verify_email_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _VerificationRepo implements EmailVerificationRepository {
  _VerificationRepo(this.result);

  final Result<void> result;

  @override
  Future<Result<void>> verifyEmail({
    required String email,
    required String code,
  }) async => result;

  @override
  Future<Result<void>> resendCode({required String email}) async =>
      const Result.ok(null);
}

class _AuthRepo implements AuthRepository {
  _AuthRepo(this.result);

  final Result<AuthUser> result;
  int loginCalls = 0;

  @override
  Future<Result<AuthUser>> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    return result;
  }

  @override
  Future<Result<void>> logout() async => const Result.ok(null);
}

void main() {
  const user = AuthUser(id: '1', email: 'nurse@hospital.com');

  Future<Result<EmailVerificationOutcome>> run(
    _VerificationRepo verify,
    _AuthRepo auth,
  ) {
    return VerifyEmailAndSignInUseCase(
      VerifyEmailUseCase(verify),
      LoginUseCase(auth),
    )(email: 'nurse@hospital.com', password: 'S3curePass!', code: '123456');
  }

  test('verifies then signs in', () async {
    final auth = _AuthRepo(const Result.ok(user));
    final result = await run(_VerificationRepo(const Result.ok(null)), auth);

    expect(result.valueOrNull, isA<VerifiedAndSignedIn>());
    expect((result.valueOrNull! as VerifiedAndSignedIn).user, user);
  });

  test('wrong code fails and never signs in', () async {
    final auth = _AuthRepo(const Result.ok(user));
    final result = await run(
      _VerificationRepo(const Result.err(ValidationFailure(statusCode: 400))),
      auth,
    );

    expect(result.failureOrNull, isA<ValidationFailure>());
    expect(auth.loginCalls, 0);
  });

  test('verified but sign-in fails asks for manual sign-in', () async {
    final result = await run(
      _VerificationRepo(const Result.ok(null)),
      _AuthRepo(const Result.err(NetworkFailure())),
    );

    expect(result.valueOrNull, isA<VerifiedSignInRequired>());
  });
}
