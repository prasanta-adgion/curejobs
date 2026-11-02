part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

/// The user tapped Sign in with a locally valid form.
final class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// The user edited a field, so server errors no longer apply.
final class LoginErrorsCleared extends LoginEvent {
  const LoginErrorsCleared();
}
