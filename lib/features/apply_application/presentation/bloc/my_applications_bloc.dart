import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/job_application.dart';
import '../../domain/usecases/get_my_applications_usecase.dart';
import '../../domain/usecases/withdraw_application_usecase.dart';

part 'my_applications_event.dart';
part 'my_applications_state.dart';

class MyApplicationsBloc
    extends Bloc<MyApplicationsEvent, MyApplicationsState> {
  MyApplicationsBloc(this._getApplications, this._withdraw)
    : super(const MyApplicationsState()) {
    on<MyApplicationsRequested>(_onRequested);
    on<MyApplicationsRefreshed>(_onRefreshed);
    on<MyApplicationsNextPageRequested>(_onNextPage);
    on<MyApplicationsFilterChanged>(_onFilterChanged);
    on<MyApplicationWithdrawRequested>(_onWithdraw);
  }

  final GetMyApplicationsUseCase _getApplications;
  final WithdrawApplicationUseCase _withdraw;

  static const _pageSize = 10;

  Future<void> _onRequested(
    MyApplicationsRequested event,
    Emitter<MyApplicationsState> emit,
  ) async {
    emit(state.copyWith(status: MyApplicationsStatus.loading));
    await _loadFirstPage(emit);
  }

  Future<void> _onRefreshed(
    MyApplicationsRefreshed event,
    Emitter<MyApplicationsState> emit,
  ) => _loadFirstPage(emit);

  /// Filters on the server: reloads page 1 with the chosen status.
  Future<void> _onFilterChanged(
    MyApplicationsFilterChanged event,
    Emitter<MyApplicationsState> emit,
  ) async {
    if (event.status == state.filter && !state.isFiltering) return;
    emit(
      state.copyWith(
        filter: () => event.status,
        isFiltering: true,
        items: const [],
        hasMore: false,
      ),
    );
    await _loadFirstPage(emit);
  }

  Future<void> _loadFirstPage(Emitter<MyApplicationsState> emit) async {
    final filter = state.filter;
    final result = await _getApplications(
      page: 1,
      limit: _pageSize,
      status: filter,
    );

    // The user picked another filter while this request was running.
    if (filter != state.filter) return;

    result.fold(
      (page) => emit(
        state.copyWith(
          status: MyApplicationsStatus.success,
          isFiltering: false,
          items: page.items,
          counts: _mergeCounts(page, filter),
          page: page.page,
          hasMore: page.hasMore,
          failure: () => null,
        ),
      ),
      (failure) => emit(
        state.copyWith(
          // Keep showing old data if we already had some.
          status: state.status == MyApplicationsStatus.success
              ? MyApplicationsStatus.success
              : MyApplicationsStatus.failure,
          isFiltering: false,
          failure: () => failure,
        ),
      ),
    );
  }

  Future<void> _onNextPage(
    MyApplicationsNextPageRequested event,
    Emitter<MyApplicationsState> emit,
  ) async {
    if (!state.hasMore ||
        state.isLoadingMore ||
        state.isLoading ||
        state.isFiltering) {
      return;
    }

    final filter = state.filter;
    emit(state.copyWith(isLoadingMore: true));
    final result = await _getApplications(
      page: state.page + 1,
      limit: _pageSize,
      status: filter,
    );
    if (filter != state.filter) return;

    result.fold(
      (page) {
        final seen = state.items.map((a) => a.id).toSet();
        emit(
          state.copyWith(
            isLoadingMore: false,
            items: [
              ...state.items,
              ...page.items.where((a) => !seen.contains(a.id)),
            ],
            counts: _mergeCounts(page, filter),
            page: page.page,
            hasMore: page.hasMore,
          ),
        );
      },
      (failure) =>
          emit(state.copyWith(isLoadingMore: false, failure: () => failure)),
    );
  }

  /// The summary and chips always show totals for every status. If the
  /// API scopes `counts` to the filter, keep the totals we already have.
  Map<ApplicationStatus, int> _mergeCounts(
    ApplicationsPage page,
    ApplicationStatus? filter,
  ) {
    if (filter == null || state.counts.isEmpty) return page.counts;
    final others = page.counts.entries.where((e) => e.key != filter);
    final scoped = others.every((e) => e.value == 0);
    return scoped ? {...state.counts, filter: page.total} : page.counts;
  }

  Future<void> _onWithdraw(
    MyApplicationWithdrawRequested event,
    Emitter<MyApplicationsState> emit,
  ) async {
    final id = event.application.id;
    if (state.withdrawingIds.contains(id)) return;

    emit(state.copyWith(withdrawingIds: {...state.withdrawingIds, id}));
    final result = await _withdraw(id);
    final remaining = {...state.withdrawingIds}..remove(id);

    if (result.failureOrNull case final failure?) {
      emit(
        state.copyWith(
          withdrawingIds: remaining,
          withdrawResult: () => WithdrawResult.failed(event.application, failure),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        withdrawingIds: remaining,
        withdrawResult: () => WithdrawResult.done(event.application),
      ),
    );
    // Reload so the row, counts and filters reflect the new status.
    await _loadFirstPage(emit);
  }
}
