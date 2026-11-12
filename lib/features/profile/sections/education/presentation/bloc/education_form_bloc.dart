import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/error/failure.dart';
import '../../domain/entities/education_params.dart';
import '../../domain/usecases/delete_education_usecase.dart';
import '../../domain/usecases/save_education_usecase.dart';

part 'education_form_event.dart';
part 'education_form_state.dart';

/// Saves (add or update) or deletes one education entry from the form
/// screen.
class EducationFormBloc extends Bloc<EducationFormEvent, EducationFormState> {
  final SaveEducationUseCase _save;
  final DeleteEducationUseCase _delete;

  EducationFormBloc(this._save, this._delete)
    : super(const EducationFormState()) {
    on<EducationFormSaved>(_onSaved);
    on<EducationFormDeleted>(_onDeleted);
  }

  Future<void> _onSaved(
    EducationFormSaved event,
    Emitter<EducationFormState> emit,
  ) async {
    if (state.isBusy) return;
    emit(const EducationFormState(status: EducationFormStatus.saving));

    final result = await _save(event.params, id: event.id);

    emit(
      result.fold(
        (_) => const EducationFormState(status: EducationFormStatus.saved),
        (failure) => EducationFormState(
          status: EducationFormStatus.failure,
          action: EducationFormAction.save,
          failure: failure,
        ),
      ),
    );
  }

  Future<void> _onDeleted(
    EducationFormDeleted event,
    Emitter<EducationFormState> emit,
  ) async {
    if (state.isBusy) return;
    emit(const EducationFormState(status: EducationFormStatus.deleting));

    final result = await _delete(event.id);

    emit(
      result.fold(
        (_) => const EducationFormState(status: EducationFormStatus.deleted),
        (failure) => EducationFormState(
          status: EducationFormStatus.failure,
          action: EducationFormAction.delete,
          failure: failure,
        ),
      ),
    );
  }
}
