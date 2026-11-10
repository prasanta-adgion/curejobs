import 'package:curejobs/app/di/injection_container.dart';
import 'package:curejobs/core/result/result.dart';
import 'package:curejobs/features/auth/login/domain/entities/auth_user.dart';
import 'package:curejobs/features/auth/login/domain/repositories/auth_repository.dart';
import 'package:curejobs/features/auth/login/domain/usecases/login_usecase.dart';
import 'package:curejobs/features/auth/otp_verification/domain/repositories/email_verification_repository.dart';
import 'package:curejobs/features/auth/otp_verification/domain/usecases/resend_verification_code_usecase.dart';
import 'package:curejobs/features/auth/otp_verification/domain/usecases/verify_email_and_sign_in_usecase.dart';
import 'package:curejobs/features/auth/otp_verification/domain/usecases/verify_email_usecase.dart';
import 'package:curejobs/features/auth/otp_verification/presentation/bloc/otp_verification_bloc.dart';
import 'package:curejobs/features/auth/otp_verification/presentation/pages/otp_verification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeVerificationRepo implements EmailVerificationRepository {
  @override
  Future<Result<void>> resendCode({required String email}) async =>
      const Result.ok(null);

  @override
  Future<Result<void>> verifyEmail({
    required String email,
    required String code,
  }) async => const Result.ok(null);
}

class _FakeAuthRepo implements AuthRepository {
  @override
  Future<Result<AuthUser>> login({
    required String email,
    required String password,
  }) async => Result.ok(AuthUser(id: '1', email: email));

  @override
  Future<Result<void>> logout() async => const Result.ok(null);
}

void main() {
  setUp(() {
    final repo = _FakeVerificationRepo();
    final verifyAndSignIn = VerifyEmailAndSignInUseCase(
      VerifyEmailUseCase(repo),
      LoginUseCase(_FakeAuthRepo()),
    );
    sl.registerFactoryParam<OtpVerificationBloc, String, String>(
      (email, password) => OtpVerificationBloc(
        verifyAndSignIn,
        ResendVerificationCodeUseCase(repo),
        email: email,
        password: password,
      ),
    );
  });

  tearDown(sl.reset);

  // Guards against widget-tree assertions (e.g. pinput 7 needing a
  // material_ui Material ancestor) that froze the screen on open.
  for (final size in const [Size(360, 740), Size(411, 891)]) {
    testWidgets('OTP page opens without errors at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const OtpVerificationPage(
                      email: 'nurse@hospital.com',
                      password: 'S3curePass!',
                    ),
                  ),
                ),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('go'));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      expect(tester.takeException(), isNull);
      expect(find.text('Check your email'), findsOneWidget);
    });
  }
}
