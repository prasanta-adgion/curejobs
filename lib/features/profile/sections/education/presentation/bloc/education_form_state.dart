part of 'education_form_bloc.dart';

enum EducationFormStatus { idle, saving, deleting, saved, deleted, failure }

enum EducationFormAction { save, delete }

class EducationFormState extends Equatable {
  final EducationFormStatus status;

  /// Which action failed, when [status] is failure.
  final EducationFormAction? action;
  final Failure? failure;

  const EducationFormState({
    this.status = EducationFormStatus.idle,
    this.action,
    this.failure,
  });

  bool get isBusy =>
      status == EducationFormStatus.saving ||
      status == EducationFormStatus.deleting;

  @override
  List<Object?> get props => [status, action, failure];
}
