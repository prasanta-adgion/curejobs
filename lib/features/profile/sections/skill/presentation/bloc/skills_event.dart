part of 'skills_bloc.dart';

sealed class SkillsEvent extends Equatable {
  const SkillsEvent();

  @override
  List<Object?> get props => [];
}

/// Load the skills, or reload them (retry / pull to refresh).
final class SkillsRequested extends SkillsEvent {
  const SkillsRequested();
}

/// The user saved a new list in the edit sheet.
final class SkillsEdited extends SkillsEvent {
  const SkillsEdited(this.names);

  final List<String> names;

  @override
  List<Object?> get props => [names];
}

/// The user tapped × on one skill chip.
final class SkillRemoved extends SkillsEvent {
  const SkillRemoved(this.skill);

  final Skill skill;

  @override
  List<Object?> get props => [skill];
}

/// The user tapped Undo after removing a skill.
final class SkillRestored extends SkillsEvent {
  const SkillRestored(this.name, {required this.index});

  final String name;

  /// Where the chip was, so it comes back in the same place.
  final int index;

  @override
  List<Object?> get props => [name, index];
}
