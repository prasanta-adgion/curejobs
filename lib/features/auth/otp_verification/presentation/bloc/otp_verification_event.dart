part of 'otp_verification_bloc.dart';

sealed class OtpVerificationEvent extends Equatable {
  const OtpVerificationEvent();

  @override
  List<Object?> get props => [];
}

/// The screen opened: start the resend countdown.
final class OtpStarted extends OtpVerificationEvent {
  const OtpStarted();
}

/// The user typed, deleted or pasted digits.
final class OtpCodeChanged extends OtpVerificationEvent {
  final String code;

  const OtpCodeChanged(this.code);

  @override
  List<Object?> get props => [code];
}

/// The user tapped Verify email, or entered the last digit.
final class OtpSubmitted extends OtpVerificationEvent {
  const OtpSubmitted();
}

/// The user tapped Resend code.
final class OtpResendRequested extends OtpVerificationEvent {
  const OtpResendRequested();
}

/// One second of the resend countdown passed.
final class _OtpResendTicked extends OtpVerificationEvent {
  final int secondsLeft;

  const _OtpResendTicked(this.secondsLeft);

  @override
  List<Object?> get props => [secondsLeft];
}
