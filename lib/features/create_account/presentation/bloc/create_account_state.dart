part of 'create_account_bloc.dart';

enum CreateAccountSubmitStatus { initial, submitting, success, failure }

class CreateAccountState extends Equatable {
  final CreateAccountSubmitStatus status;

  /// Set when saving fails.
  final Failure? failure;

  const CreateAccountState({
    this.status = CreateAccountSubmitStatus.initial,
    this.failure,
  });

  bool get isSubmitting => status == CreateAccountSubmitStatus.submitting;

  @override
  List<Object?> get props => [status, failure];
}
