part of 'experience_form_bloc.dart';

sealed class ExperienceFormEvent extends Equatable {
  const ExperienceFormEvent();

  @override
  List<Object?> get props => [];
}

/// Save the form. Adds a new position when [id] is null.
final class ExperienceFormSaved extends ExperienceFormEvent {
  const ExperienceFormSaved(this.params, {this.id});

  final ExperienceParams params;
  final String? id;

  @override
  List<Object?> get props => [params, id];
}

/// Delete the position being edited.
final class ExperienceFormDeleted extends ExperienceFormEvent {
  const ExperienceFormDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
