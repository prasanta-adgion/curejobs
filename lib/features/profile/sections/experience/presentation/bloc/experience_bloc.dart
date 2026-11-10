import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/error/failure.dart';
import '../../domain/entities/experience.dart';
import '../../domain/usecases/delete_experience_usecase.dart';
import '../../domain/usecases/get_experience_usecase.dart';

part 'experience_event.dart';
part 'experience_state.dart';

/// Loads the candidate's work history and deletes positions from the list.
class ExperienceBloc extends Bloc<ExperienceEvent, ExperienceState> {
  final GetExperienceUseCase _getExperience;
  final DeleteExperienceUseCase _deleteExperience;

  ExperienceBloc(this._getExperience, this._deleteExperience)
    : super(const ExperienceState()) {
    on<ExperienceRequested>(_onRequested);
    on<ExperienceDeleted>(_onDeleted);
  }

  Future<void> _onRequested(
    ExperienceRequested event,
    Emitter<ExperienceState> emit,
  ) async {
    if (state.status == ExperienceStatus.loading) return;
    emit(state.copyWith(status: ExperienceStatus.loading));

    final result = await _getExperience();

    result.fold(
      (items) =>
          emit(state.copyWith(status: ExperienceStatus.success, items: items)),
      (failure) => emit(
        state.copyWith(status: ExperienceStatus.failure, failure: failure),
      ),
    );
  }

  /// Removes the item right away and puts it back if the call fails.
  Future<void> _onDeleted(
    ExperienceDeleted event,
    Emitter<ExperienceState> emit,
  ) async {
    final before = state.items;
    final index = before.indexWhere((e) => e.id == event.id);
    if (index < 0) return;

    emit(
      state.copyWith(items: [...before]..removeAt(index), deleteFailure: null),
    );

    final result = await _deleteExperience(event.id);

    result.fold(
      (_) {},
      (failure) => emit(
        state.copyWith(
          items: [...state.items]..insert(index, before[index]),
          deleteFailure: failure,
        ),
      ),
    );
  }
}
