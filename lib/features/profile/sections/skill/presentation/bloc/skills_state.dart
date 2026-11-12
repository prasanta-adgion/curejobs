part of 'skills_bloc.dart';

enum SkillsStatus { initial, loading, success, failure }

/// Progress of the last save from the edit sheet.
enum SkillsSaveStatus { idle, saving, saved, failed }

/// A skill that was just removed, and where it was, so it can be undone.
class RemovedSkill extends Equatable {
  const RemovedSkill(this.skill, this.index);

  final Skill skill;
  final int index;

  @override
  List<Object?> get props => [skill, index];
}

class SkillsState extends Equatable {
  final SkillsStatus status;
  final List<Skill> items;

  /// Set when loading fails.
  final Failure? failure;

  final SkillsSaveStatus saveStatus;

  /// Set when saving fails; the list is reloaded to show what was saved.
  final Failure? saveFailure;

  /// Ids of skills whose delete request is still running.
  final Set<String> removingIds;

  /// Set for one state right after a delete succeeds, to offer Undo.
  final RemovedSkill? removed;

  /// Set for one state when removing or restoring a single skill fails.
  final Failure? actionFailure;

  const SkillsState({
    this.status = SkillsStatus.initial,
    this.items = const [],
    this.failure,
    this.saveStatus = SkillsSaveStatus.idle,
    this.saveFailure,
    this.removingIds = const {},
    this.removed,
    this.actionFailure,
  });

  bool get isLoading =>
      status == SkillsStatus.initial || status == SkillsStatus.loading;

  bool get isSaving => saveStatus == SkillsSaveStatus.saving;

  bool isRemoving(Skill skill) => removingIds.contains(skill.id);

  /// Skills still on the profile, not counting ones being removed.
  int get visibleCount =>
      items.where((s) => !removingIds.contains(s.id)).length;

  List<String> get names => [for (final s in items) s.name];

  /// [failure], [saveFailure], [removed] and [actionFailure] are one-off
  /// values and reset unless passed again.
  SkillsState copyWith({
    SkillsStatus? status,
    List<Skill>? items,
    Failure? failure,
    SkillsSaveStatus? saveStatus,
    Failure? saveFailure,
    Set<String>? removingIds,
    RemovedSkill? removed,
    Failure? actionFailure,
  }) {
    return SkillsState(
      status: status ?? this.status,
      items: items ?? this.items,
      failure: failure,
      saveStatus: saveStatus ?? this.saveStatus,
      saveFailure: saveFailure,
      removingIds: removingIds ?? this.removingIds,
      removed: removed,
      actionFailure: actionFailure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    failure,
    saveStatus,
    saveFailure,
    removingIds,
    removed,
    actionFailure,
  ];
}
