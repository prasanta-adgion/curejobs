part of 'otp_verification_bloc.dart';

enum OtpStatus { editing, verifying, verified, failure }

class OtpVerificationState extends Equatable {
  final String email;
  final String code;
  final OtpStatus status;

  /// Seconds until Resend code is available; 0 means available now.
  final int resendIn;
  final bool isResending;

  /// Increments each time a new code is sent, so the UI can confirm it once.
  final int codesSent;

  /// Shown under the code boxes; also turns the boxes red.
  final String? errorMessage;

  /// Set when the code was accepted and the automatic sign-in worked.
  /// Verified with no user means the user must sign in manually.
  final AuthUser? user;

  bool get isSignedIn => user != null;

  const OtpVerificationState({
    required this.email,
    this.code = '',
    this.status = OtpStatus.editing,
    this.resendIn = 0,
    this.isResending = false,
    this.codesSent = 0,
    this.errorMessage,
    this.user,
  });

  bool get isVerifying => status == OtpStatus.verifying;
  bool get isComplete => code.length == OtpVerificationBloc.codeLength;
  bool get canSubmit =>
      isComplete && !isVerifying && status != OtpStatus.verified;
  bool get canResend => resendIn == 0 && !isResending && !isVerifying;
  bool get hasError => errorMessage != null;

  OtpVerificationState copyWith({
    String? code,
    OtpStatus? status,
    int? resendIn,
    bool? isResending,
    int? codesSent,
    String? Function()? errorMessage,
    AuthUser? user,
  }) {
    return OtpVerificationState(
      email: email,
      code: code ?? this.code,
      status: status ?? this.status,
      resendIn: resendIn ?? this.resendIn,
      isResending: isResending ?? this.isResending,
      codesSent: codesSent ?? this.codesSent,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
    email,
    code,
    status,
    resendIn,
    isResending,
    codesSent,
    errorMessage,
    user,
  ];
}
