part of 'create_account_bloc.dart';

sealed class CreateAccountEvent extends Equatable {
  const CreateAccountEvent();

  @override
  List<Object?> get props => [];
}

/// Finish was tapped: save the profile.
final class CreateAccountSubmitted extends CreateAccountEvent {
  final CreateAccountParams params;

  const CreateAccountSubmitted(this.params);

  @override
  List<Object?> get props => [params];
}
