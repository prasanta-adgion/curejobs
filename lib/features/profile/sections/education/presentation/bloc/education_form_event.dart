part of 'education_form_bloc.dart';

sealed class EducationFormEvent extends Equatable {
  const EducationFormEvent();

  @override
  List<Object?> get props => [];
}

/// Save the form. Adds new education when [id] is null.
final class EducationFormSaved extends EducationFormEvent {
  const EducationFormSaved(this.params, {this.id});

  final EducationParams params;
  final String? id;

  @override
  List<Object?> get props => [params, id];
}

/// Delete the education being edited.
final class EducationFormDeleted extends EducationFormEvent {
  const EducationFormDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
