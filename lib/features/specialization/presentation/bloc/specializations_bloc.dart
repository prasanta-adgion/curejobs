import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/specialization.dart';
import '../../domain/usecases/get_specializations_usecase.dart';

part 'specializations_event.dart';
part 'specializations_state.dart';

/// Loads the specializations of the chosen category.
class SpecializationsBloc
    extends Bloc<SpecializationsEvent, SpecializationsState> {
  final GetSpecializationsUseCase _getSpecializations;

  SpecializationsBloc(this._getSpecializations)
    : super(const SpecializationsState()) {
    on<SpecializationsRequested>(_onRequested);
  }

  Future<void> _onRequested(
    SpecializationsRequested event,
    Emitter<SpecializationsState> emit,
  ) async {
    final categoryId = event.categoryId;
    if (state.status == SpecializationsStatus.loading &&
        state.categoryId == categoryId) {
      return;
    }
    emit(
      SpecializationsState(
        status: SpecializationsStatus.loading,
        categoryId: categoryId,
      ),
    );

    final result = await _getSpecializations(categoryId: categoryId);

    // The user picked another category while this one was loading.
    if (state.categoryId != categoryId) return;

    result.fold(
      (specializations) => emit(
        SpecializationsState(
          status: SpecializationsStatus.success,
          categoryId: categoryId,
          specializations: specializations,
        ),
      ),
      (failure) => emit(
        SpecializationsState(
          status: SpecializationsStatus.failure,
          categoryId: categoryId,
          failure: failure,
        ),
      ),
    );
  }
}
