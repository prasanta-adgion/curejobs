import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/error/failure.dart';
import '../../domain/entities/education.dart';
import '../../domain/usecases/delete_education_usecase.dart';
import '../../domain/usecases/get_education_usecase.dart';

part 'education_event.dart';
part 'education_state.dart';

/// Loads the candidate's education history and deletes entries from the
/// list. Adding and editing happen on [EducationFormBloc]'s screen.
class EducationBloc extends Bloc<EducationEvent, EducationState> {
  final GetEducationUseCase _getEducation;
  final DeleteEducationUseCase _deleteEducation;

  EducationBloc({
    required GetEducationUseCase getEducation,
    required DeleteEducationUseCase deleteEducation,
  }) : _getEducation = getEducation,
       _deleteEducation = deleteEducation,
       super(const EducationState()) {
    on<EducationRequested>(_onRequested);
    on<EducationDeleted>(_onDeleted);
  }

  Future<void> _onRequested(
    EducationRequested event,
    Emitter<EducationState> emit,
  ) async {
    if (state.status == EducationStatus.loading) return;
    emit(state.copyWith(status: EducationStatus.loading));
    await _load(emit);
  }

  Future<void> _load(Emitter<EducationState> emit) async {
    final result = await _getEducation();
    result.fold(
      (items) =>
          emit(state.copyWith(status: EducationStatus.success, items: items)),
      (failure) => emit(
        state.copyWith(status: EducationStatus.failure, failure: failure),
      ),
    );
  }

  /// Keeps the card with a spinner until the server confirms.
  Future<void> _onDeleted(
    EducationDeleted event,
    Emitter<EducationState> emit,
  ) async {
    final education = event.education;
    if (state.isDeleting(education)) return;
    emit(state.copyWith(deletingIds: {...state.deletingIds, education.id}));

    final result = await _deleteEducation(education.id);
    final remaining = {...state.deletingIds}..remove(education.id);

    result.fold(
      (_) => emit(
        state.copyWith(
          items: [...state.items]..removeWhere((e) => e.id == education.id),
          deletingIds: remaining,
          deleted: true,
        ),
      ),
      (failure) =>
          emit(state.copyWith(deletingIds: remaining, actionFailure: failure)),
    );
  }
}
