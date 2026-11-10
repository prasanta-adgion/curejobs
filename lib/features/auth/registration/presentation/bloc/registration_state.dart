part of 'registration_bloc.dart';

enum RegistrationStatus { initial, loading, success, failure }

class RegistrationState extends Equatable {
  final RegistrationStatus status;
  final RegistrationResult? result;

  /// Form-level error shown above the Create account button.
  final String? errorMessage;

  /// Server-side errors for individual fields.
  final String? emailError;
  final String? passwordError;

  /// Set only on success, so the next step can sign the user in. Memory
  /// only; never logged (excluded from [props] and so from toString).
  final String? password;

  const RegistrationState({
    this.status = RegistrationStatus.initial,
    this.result,
    this.errorMessage,
    this.emailError,
    this.passwordError,
    this.password,
  });

  bool get isLoading => status == RegistrationStatus.loading;

  @override
  List<Object?> get props => [
    status,
    result,
    errorMessage,
    emailError,
    passwordError,
  ];
}
