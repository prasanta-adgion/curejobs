part of 'login_cubit.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final LoginStatus status;
  final AuthUser? user;

  /// Form-level error shown above the sign-in button.
  final String? errorMessage;

  /// Server-side errors for individual fields.
  final String? emailError;
  final String? passwordError;

  const LoginState({
    this.status = LoginStatus.initial,
    this.user,
    this.errorMessage,
    this.emailError,
    this.passwordError,
  });

  bool get isLoading => status == LoginStatus.loading;

  @override
  List<Object?> get props => [
    status,
    user,
    errorMessage,
    emailError,
    passwordError,
  ];
}
