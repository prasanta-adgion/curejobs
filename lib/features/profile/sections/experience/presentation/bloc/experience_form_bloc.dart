import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/error/failure.dart';
import '../../domain/entities/experience_params.dart';
import '../../domain/usecases/delete_experience_usecase.dart';
import '../../domain/usecases/save_experience_usecase.dart';

part 'experience_form_event.dart';
part 'experience_form_state.dart';

/// Saves (add or update) or deletes one position from the form screen.
class ExperienceFormBloc
    extends Bloc<ExperienceFormEvent, ExperienceFormState> {
  final SaveExperienceUseCase _save;
  final DeleteExperienceUseCase _delete;

  ExperienceFormBloc(this._save, this._delete)
    : super(const ExperienceFormState()) {
    on<ExperienceFormSaved>(_onSaved);
    on<ExperienceFormDeleted>(_onDeleted);
  }

  Future<void> _onSaved(
    ExperienceFormSaved event,
    Emitter<ExperienceFormState> emit,
  ) async {
    if (state.isBusy) return;
    emit(const ExperienceFormState(status: ExperienceFormStatus.saving));

    final result = await _save(event.params, id: event.id);

    emit(
      result.fold(
        (_) => const ExperienceFormState(status: ExperienceFormStatus.saved),
        (failure) => ExperienceFormState(
          status: ExperienceFormStatus.failure,
          action: ExperienceFormAction.save,
          failure: failure,
        ),
      ),
    );
  }

  Future<void> _onDeleted(
    ExperienceFormDeleted event,
    Emitter<ExperienceFormState> emit,
  ) async {
    if (state.isBusy) return;
    emit(const ExperienceFormState(status: ExperienceFormStatus.deleting));

    final result = await _delete(event.id);

    emit(
      result.fold(
        (_) => const ExperienceFormState(status: ExperienceFormStatus.deleted),
        (failure) => ExperienceFormState(
          status: ExperienceFormStatus.failure,
          action: ExperienceFormAction.delete,
          failure: failure,
        ),
      ),
    );
  }
}
