import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/plan_history_entry.dart';
import '../../domain/usecases/get_plan_history_usecase.dart';

part 'plan_history_event.dart';
part 'plan_history_state.dart';

/// Loads plan history page by page for the Plan history tab.
class PlanHistoryBloc extends Bloc<PlanHistoryEvent, PlanHistoryState> {
  PlanHistoryBloc(this._getHistory) : super(const PlanHistoryState()) {
    on<PlanHistoryRequested>(_onRequested);
    // Extra scroll triggers are ignored via `isLoadingMore`.
    on<PlanHistoryNextPageRequested>(_onNextPage);
  }

  final GetPlanHistoryUseCase _getHistory;

  static const _pageSize = 10;

  Future<void> _onRequested(
    PlanHistoryRequested event,
    Emitter<PlanHistoryState> emit,
  ) async {
    if (state.items.isEmpty) emit(const PlanHistoryState());
    final result = await _getHistory(page: 1, limit: _pageSize);
    result.fold(
      (page) => emit(
        PlanHistoryState(
          status: PlanHistoryStatus.success,
          items: page.items,
          page: page.page,
          hasMore: page.hasMore,
          total: page.total,
        ),
      ),
      (f) =>
          emit(state.copyWith(status: PlanHistoryStatus.failure, failure: f)),
    );
  }

  Future<void> _onNextPage(
    PlanHistoryNextPageRequested event,
    Emitter<PlanHistoryState> emit,
  ) async {
    if (!state.hasMore || state.isLoadingMore) return;
    if (state.status != PlanHistoryStatus.success) return;

    emit(state.copyWith(isLoadingMore: true, clearLoadMoreFailure: true));
    final result = await _getHistory(page: state.page + 1, limit: _pageSize);
    result.fold((page) {
      // Skip rows already shown, in case the list shifted between pages.
      final seen = {for (final e in state.items) e.id};
      emit(
        state.copyWith(
          items: [
            ...state.items,
            ...page.items.where((e) => !seen.contains(e.id)),
          ],
          page: page.page,
          hasMore: page.hasMore,
          total: page.total,
          isLoadingMore: false,
        ),
      );
    }, (f) => emit(state.copyWith(isLoadingMore: false, loadMoreFailure: f)));
  }
}
