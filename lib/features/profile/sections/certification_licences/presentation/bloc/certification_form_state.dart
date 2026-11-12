part of 'certification_form_bloc.dart';

enum CertificationFormStatus { idle, saving, deleting, saved, deleted, failure }

enum CertificationFormAction { save, delete }

class CertificationFormState extends Equatable {
  final CertificationFormStatus status;

  /// Which action failed, when [status] is failure.
  final CertificationFormAction? action;
  final Failure? failure;

  const CertificationFormState({
    this.status = CertificationFormStatus.idle,
    this.action,
    this.failure,
  });

  bool get isBusy =>
      status == CertificationFormStatus.saving ||
      status == CertificationFormStatus.deleting;

  @override
  List<Object?> get props => [status, action, failure];
}
