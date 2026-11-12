part of 'certification_form_bloc.dart';

sealed class CertificationFormEvent extends Equatable {
  const CertificationFormEvent();

  @override
  List<Object?> get props => [];
}

/// Save the form. Adds a new certificate when [id] is null.
final class CertificationFormSaved extends CertificationFormEvent {
  const CertificationFormSaved(this.params, {this.id});

  final CertificationParams params;
  final String? id;

  @override
  List<Object?> get props => [params, id];
}

/// Delete the certificate being edited.
final class CertificationFormDeleted extends CertificationFormEvent {
  const CertificationFormDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
