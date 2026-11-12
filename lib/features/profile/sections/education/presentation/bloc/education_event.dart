part of 'education_bloc.dart';

sealed class EducationEvent extends Equatable {
  const EducationEvent();

  @override
  List<Object?> get props => [];
}

/// Load the education list, or reload it (retry, pull to refresh, or after
/// the form saves).
final class EducationRequested extends EducationEvent {
  const EducationRequested();
}

/// Delete one entry from the list.
final class EducationDeleted extends EducationEvent {
  const EducationDeleted(this.education);

  final Education education;

  @override
  List<Object?> get props => [education];
}
