import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/error/failure.dart';
import '../../domain/entities/skill.dart';
import '../../domain/usecases/add_skill_usecase.dart';
import '../../domain/usecases/delete_skill_usecase.dart';
import '../../domain/usecases/get_skills_usecase.dart';
import '../../domain/usecases/update_skills_usecase.dart';

part 'skills_event.dart';
part 'skills_state.dart';

/// Loads the candidate's skills, saves edits from the sheet, and removes or
/// restores single skills from the chips.
class SkillsBloc extends Bloc<SkillsEvent, SkillsState> {
  final GetSkillsUseCase _getSkills;
  final UpdateSkillsUseCase _updateSkills;
  final AddSkillUseCase _addSkill;
  final DeleteSkillUseCase _deleteSkill;

  SkillsBloc({
    required GetSkillsUseCase getSkills,
    required UpdateSkillsUseCase updateSkills,
    required AddSkillUseCase addSkill,
    required DeleteSkillUseCase deleteSkill,
  }) : _getSkills = getSkills,
       _updateSkills = updateSkills,
       _addSkill = addSkill,
       _deleteSkill = deleteSkill,
       super(const SkillsState()) {
    on<SkillsRequested>(_onRequested);
    on<SkillsEdited>(_onEdited);
    on<SkillRemoved>(_onRemoved);
    on<SkillRestored>(_onRestored);
  }

  Future<void> _onRequested(
    SkillsRequested event,
    Emitter<SkillsState> emit,
  ) async {
    if (state.status == SkillsStatus.loading) return;
    emit(state.copyWith(status: SkillsStatus.loading));
    await _load(emit);
  }

  Future<void> _load(Emitter<SkillsState> emit) async {
    final result = await _getSkills();
    result.fold(
      (items) =>
          emit(state.copyWith(status: SkillsStatus.success, items: items)),
      (failure) =>
          emit(state.copyWith(status: SkillsStatus.failure, failure: failure)),
    );
  }

  /// Shows the new list right away, saves it, then reloads so ids and
  /// spelling match the server. On failure the reload shows what was saved.
  Future<void> _onEdited(SkillsEdited event, Emitter<SkillsState> emit) async {
    if (state.isSaving) return;
    final before = state.items;

    final existing = {for (final s in before) s.normalizedName: s};
    final optimistic = [
      for (final name in event.names)
        existing[name.toLowerCase()] ??
            Skill(id: '', name: name, normalizedName: name.toLowerCase()),
    ];
    emit(
      state.copyWith(items: optimistic, saveStatus: SkillsSaveStatus.saving),
    );

    final result = await _updateSkills(current: before, names: event.names);

    final failure = result.failureOrNull;
    emit(
      state.copyWith(
        saveStatus: failure == null
            ? SkillsSaveStatus.saved
            : SkillsSaveStatus.failed,
        saveFailure: failure,
      ),
    );
    await _load(emit);
  }

  /// Keeps the chip on screen with a spinner until the server confirms, then
  /// drops it and offers Undo. On failure the chip simply stays.
  Future<void> _onRemoved(SkillRemoved event, Emitter<SkillsState> emit) async {
    final skill = event.skill;
    if (skill.id.isEmpty || state.isRemoving(skill) || state.isSaving) return;

    emit(state.copyWith(removingIds: {...state.removingIds, skill.id}));

    final result = await _deleteSkill(skill.id);
    final remaining = {...state.removingIds}..remove(skill.id);

    result.fold(
      (_) {
        final index = state.items.indexWhere((s) => s.id == skill.id);
        emit(
          state.copyWith(
            items: [...state.items]..removeWhere((s) => s.id == skill.id),
            removingIds: remaining,
            removed: RemovedSkill(
              skill,
              index < 0 ? state.items.length : index,
            ),
          ),
        );
      },
      (failure) =>
          emit(state.copyWith(removingIds: remaining, actionFailure: failure)),
    );
  }

  /// Adds the skill back, then reloads to pick up its new id.
  Future<void> _onRestored(
    SkillRestored event,
    Emitter<SkillsState> emit,
  ) async {
    final name = event.name;
    if (state.items.any((s) => s.normalizedName == name.toLowerCase())) return;

    // Put it back where it was while the request runs.
    final placeholder = Skill(
      id: '',
      name: name,
      normalizedName: name.toLowerCase(),
    );
    final at = event.index.clamp(0, state.items.length);
    emit(state.copyWith(items: [...state.items]..insert(at, placeholder)));

    final result = await _addSkill(name);
    final failure = result.failureOrNull;
    if (failure != null) {
      emit(
        state.copyWith(
          items: [...state.items]..remove(placeholder),
          actionFailure: failure,
        ),
      );
      return;
    }
    await _load(emit);
  }
}
