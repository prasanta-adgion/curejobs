part of 'registration_bloc.dart';

sealed class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object?> get props => [];
}

/// The user tapped Create account with a locally valid form.
final class RegistrationSubmitted extends RegistrationEvent {
  final String email;
  final String password;

  const RegistrationSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// The user edited a field, so server errors no longer apply.
final class RegistrationErrorsCleared extends RegistrationEvent {
  const RegistrationErrorsCleared();
}
