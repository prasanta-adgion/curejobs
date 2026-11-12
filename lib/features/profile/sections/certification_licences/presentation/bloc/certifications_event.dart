part of 'certifications_bloc.dart';

sealed class CertificationsEvent extends Equatable {
  const CertificationsEvent();

  @override
  List<Object?> get props => [];
}

/// Load the list, or reload it (retry, or after the form saves).
final class CertificationsRequested extends CertificationsEvent {
  const CertificationsRequested();
}

/// Delete one certificate from the list.
final class CertificationDeleted extends CertificationsEvent {
  const CertificationDeleted(this.certification);

  final Certification certification;

  @override
  List<Object?> get props => [certification];
}
