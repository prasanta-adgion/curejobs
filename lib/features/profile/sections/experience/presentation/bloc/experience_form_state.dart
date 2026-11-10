part of 'experience_form_bloc.dart';

enum ExperienceFormStatus { idle, saving, deleting, saved, deleted, failure }

enum ExperienceFormAction { save, delete }

class ExperienceFormState extends Equatable {
  final ExperienceFormStatus status;

  /// Which action failed, when [status] is failure.
  final ExperienceFormAction? action;
  final Failure? failure;

  const ExperienceFormState({
    this.status = ExperienceFormStatus.idle,
    this.action,
    this.failure,
  });

  bool get isBusy =>
      status == ExperienceFormStatus.saving ||
      status == ExperienceFormStatus.deleting;

  @override
  List<Object?> get props => [status, action, failure];
}
