part of 'education_bloc.dart';

sealed class EducationEvent extends Equatable {
  const EducationEvent();

  @override
  List<Object?> get props => [];
}

/// Load the education list, or reload it (retry / after a save).
final class EducationRequested extends EducationEvent {
  const EducationRequested();
}
