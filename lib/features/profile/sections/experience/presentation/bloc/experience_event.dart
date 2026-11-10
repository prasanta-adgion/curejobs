part of 'experience_bloc.dart';

sealed class ExperienceEvent extends Equatable {
  const ExperienceEvent();

  @override
  List<Object?> get props => [];
}

/// Load the work history, or reload it (retry / after a save).
final class ExperienceRequested extends ExperienceEvent {
  const ExperienceRequested();
}

/// Delete one position from the list.
final class ExperienceDeleted extends ExperienceEvent {
  const ExperienceDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
