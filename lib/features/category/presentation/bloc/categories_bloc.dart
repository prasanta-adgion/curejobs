import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/get_categories_usecase.dart';

part 'categories_event.dart';
part 'categories_state.dart';

/// Loads the job categories.
class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final GetCategoriesUseCase _getCategories;

  CategoriesBloc(this._getCategories) : super(const CategoriesState()) {
    on<CategoriesRequested>(_onRequested);
  }

  Future<void> _onRequested(
    CategoriesRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    if (state.status == CategoriesStatus.loading) return;
    emit(
      CategoriesState(
        status: CategoriesStatus.loading,
        categories: state.categories,
      ),
    );

    final result = await _getCategories();

    result.fold(
      (categories) => emit(
        CategoriesState(
          status: CategoriesStatus.success,
          categories: categories,
        ),
      ),
      (failure) => emit(
        CategoriesState(
          status: CategoriesStatus.failure,
          categories: state.categories,
          failure: failure,
        ),
      ),
    );
  }
}
