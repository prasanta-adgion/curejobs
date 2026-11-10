import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/error/failure.dart';
import '../../domain/entities/education.dart';
import '../../domain/usecases/get_education_usecase.dart';

part 'education_event.dart';
part 'education_state.dart';

/// Loads the candidate's education history.
class EducationBloc extends Bloc<EducationEvent, EducationState> {
  final GetEducationUseCase _getEducation;

  EducationBloc(this._getEducation) : super(const EducationState()) {
    on<EducationRequested>(_onRequested);
  }

  Future<void> _onRequested(
    EducationRequested event,
    Emitter<EducationState> emit,
  ) async {
    if (state.status == EducationStatus.loading) return;
    emit(EducationState(status: EducationStatus.loading, items: state.items));

    final result = await _getEducation();

    result.fold(
      (items) =>
          emit(EducationState(status: EducationStatus.success, items: items)),
      (failure) => emit(
        EducationState(
          status: EducationStatus.failure,
          items: state.items,
          failure: failure,
        ),
      ),
    );
  }
}
