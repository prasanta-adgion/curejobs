import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/application_eligibility.dart';
import '../../domain/usecases/submit_application_usecase.dart';

part 'submit_application_event.dart';
part 'submit_application_state.dart';

/// Sends the application from the review step.
class SubmitApplicationBloc
    extends Bloc<SubmitApplicationEvent, SubmitApplicationState> {
  SubmitApplicationBloc(this._submit) : super(const SubmitApplicationState()) {
    on<SubmitApplicationRequested>(_onRequested);
  }

  final SubmitApplicationUseCase _submit;

  Future<void> _onRequested(
    SubmitApplicationRequested event,
    Emitter<SubmitApplicationState> emit,
  ) async {
    if (state.isSending) return;
    emit(const SubmitApplicationState(status: SubmitStatus.sending));

    final result = await _submit(
      jobId: event.jobId,
      resumeId: event.resumeId,
      answers: event.answers,
    );
    result.fold(
      (_) => emit(const SubmitApplicationState(status: SubmitStatus.success)),
      (failure) => emit(
        SubmitApplicationState(status: SubmitStatus.failure, failure: failure),
      ),
    );
  }
}
