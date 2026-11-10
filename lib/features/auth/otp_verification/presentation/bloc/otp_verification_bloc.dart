import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure.dart';
import '../../../login/domain/entities/auth_user.dart';
import '../../domain/usecases/resend_verification_code_usecase.dart';
import '../../domain/usecases/verify_email_and_sign_in_usecase.dart';

part 'otp_verification_event.dart';
part 'otp_verification_state.dart';

class OtpVerificationBloc
    extends Bloc<OtpVerificationEvent, OtpVerificationState> {
  static const int codeLength = 6;
  static const int resendCooldownSeconds = 60;

  final VerifyEmailAndSignInUseCase _verifyAndSignIn;
  final ResendVerificationCodeUseCase _resendCode;

  /// Used once, to sign in after verification. Kept in memory only.
  final String _password;
  StreamSubscription<int>? _countdown;

  OtpVerificationBloc(
    this._verifyAndSignIn,
    this._resendCode, {
    required String email,
    required String password,
  }) : _password = password,
       super(OtpVerificationState(email: email)) {
    on<OtpStarted>((_, _) => _startCountdown());
    on<OtpCodeChanged>(_onCodeChanged);
    on<OtpSubmitted>(_onSubmitted);
    on<OtpResendRequested>(_onResendRequested);
    on<_OtpResendTicked>(
      (event, emit) => emit(state.copyWith(resendIn: event.secondsLeft)),
    );
  }

  void _onCodeChanged(
    OtpCodeChanged event,
    Emitter<OtpVerificationState> emit,
  ) {
    if (event.code == state.code) return;
    // Editing after a wrong code clears the error.
    emit(
      state.copyWith(
        code: event.code,
        status: state.status == OtpStatus.failure ? OtpStatus.editing : null,
        errorMessage: () => null,
      ),
    );
  }

  Future<void> _onSubmitted(
    OtpSubmitted event,
    Emitter<OtpVerificationState> emit,
  ) async {
    if (!state.canSubmit) return;
    emit(state.copyWith(status: OtpStatus.verifying, errorMessage: () => null));

    final result = await _verifyAndSignIn(
      email: state.email,
      password: _password,
      code: state.code,
    );

    result.fold(
      (outcome) {
        _countdown?.cancel();
        emit(
          state.copyWith(
            status: OtpStatus.verified,
            user: switch (outcome) {
              VerifiedAndSignedIn(:final user) => user,
              VerifiedSignInRequired() => null,
            },
          ),
        );
      },
      (failure) => emit(
        state.copyWith(
          status: OtpStatus.failure,
          errorMessage: () => _verifyMessage(failure),
        ),
      ),
    );
  }

  Future<void> _onResendRequested(
    OtpResendRequested event,
    Emitter<OtpVerificationState> emit,
  ) async {
    if (!state.canResend) return;
    emit(state.copyWith(isResending: true, errorMessage: () => null));

    final result = await _resendCode(email: state.email);

    result.fold(
      (_) {
        emit(
          state.copyWith(
            isResending: false,
            code: '',
            status: OtpStatus.editing,
            codesSent: state.codesSent + 1,
          ),
        );
        _startCountdown();
      },
      (failure) => emit(
        state.copyWith(
          isResending: false,
          errorMessage: () => failure is RateLimitFailure
              ? 'Too many requests. Wait a moment, then try again.'
              : failure.message,
        ),
      ),
    );
  }

  void _startCountdown() {
    _countdown?.cancel();
    add(const _OtpResendTicked(resendCooldownSeconds));
    _countdown =
        Stream.periodic(
          const Duration(seconds: 1),
          (tick) => resendCooldownSeconds - tick - 1,
        ).take(resendCooldownSeconds).listen((left) {
          if (!isClosed) add(_OtpResendTicked(left));
        });
  }

  String _verifyMessage(Failure failure) {
    return switch (failure) {
      ValidationFailure() =>
        failure.errorFor('code') ??
            "That code isn't right. Check it and try again.",
      NotFoundFailure() || ConflictFailure() => failure.message,
      RateLimitFailure() => 'Too many attempts. Wait a moment, then try again.',
      _ => failure.message,
    };
  }

  @override
  Future<void> close() {
    _countdown?.cancel();
    return super.close();
  }
}
