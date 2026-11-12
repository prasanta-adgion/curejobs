import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/error/failure.dart';
import '../../domain/entities/certification_params.dart';
import '../../domain/usecases/delete_certification_usecase.dart';
import '../../domain/usecases/save_certification_usecase.dart';

part 'certification_form_event.dart';
part 'certification_form_state.dart';

/// Saves (add or update) or deletes one certificate from the form
/// screen.
class CertificationFormBloc
    extends Bloc<CertificationFormEvent, CertificationFormState> {
  final SaveCertificationUseCase _save;
  final DeleteCertificationUseCase _delete;

  CertificationFormBloc(this._save, this._delete)
    : super(const CertificationFormState()) {
    on<CertificationFormSaved>(_onSaved);
    on<CertificationFormDeleted>(_onDeleted);
  }

  Future<void> _onSaved(
    CertificationFormSaved event,
    Emitter<CertificationFormState> emit,
  ) async {
    if (state.isBusy) return;
    emit(const CertificationFormState(status: CertificationFormStatus.saving));

    final result = await _save(event.params, id: event.id);

    emit(
      result.fold(
        (_) =>
            const CertificationFormState(status: CertificationFormStatus.saved),
        (failure) => CertificationFormState(
          status: CertificationFormStatus.failure,
          action: CertificationFormAction.save,
          failure: failure,
        ),
      ),
    );
  }

  Future<void> _onDeleted(
    CertificationFormDeleted event,
    Emitter<CertificationFormState> emit,
  ) async {
    if (state.isBusy) return;
    emit(
      const CertificationFormState(status: CertificationFormStatus.deleting),
    );

    final result = await _delete(event.id);

    emit(
      result.fold(
        (_) => const CertificationFormState(
          status: CertificationFormStatus.deleted,
        ),
        (failure) => CertificationFormState(
          status: CertificationFormStatus.failure,
          action: CertificationFormAction.delete,
          failure: failure,
        ),
      ),
    );
  }
}
