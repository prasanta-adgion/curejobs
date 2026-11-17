part of 'submit_application_bloc.dart';

enum SubmitStatus { idle, sending, success, failure }

class SubmitApplicationState extends Equatable {
  const SubmitApplicationState({this.status = SubmitStatus.idle, this.failure});

  final SubmitStatus status;

  /// Set when sending fails.
  final Failure? failure;

  bool get isSending => status == SubmitStatus.sending;

  @override
  List<Object?> get props => [status, failure];
}
