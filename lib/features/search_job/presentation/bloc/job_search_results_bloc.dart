import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../../all_jobs/domain/entities/job.dart';
import '../../domain/entities/search_query.dart';
import '../../domain/usecases/search_jobs_usecase.dart';

part 'job_search_results_event.dart';
part 'job_search_results_state.dart';

/// Search results with paging. A new search drops replies from older ones.
class JobSearchResultsBloc
    extends Bloc<JobSearchResultsEvent, JobSearchResultsState> {
  JobSearchResultsBloc(this._search) : super(const JobSearchResultsState()) {
    on<JobSearchRequested>(_onRequested);
    on<JobSearchNextPageRequested>(_onNextPage);
  }

  final SearchJobsUseCase _search;

  /// Bumped on every new search; older replies are ignored.
  int _latest = 0;

  Future<void> _onRequested(
    JobSearchRequested event,
    Emitter<JobSearchResultsState> emit,
  ) async {
    final id = ++_latest;
    emit(
      JobSearchResultsState(
        status: JobSearchResultsStatus.loading,
        query: event.query,
      ),
    );
    final result = await _search(event.query);
    if (id != _latest) return;
    switch (result) {
      case Ok(:final value):
        emit(
          state.copyWith(
            status: JobSearchResultsStatus.success,
            jobs: value.jobs,
            page: value.page,
            total: value.total,
            hasMore: value.hasMore,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            status: JobSearchResultsStatus.failure,
            errorMessage: () => failure.message,
          ),
        );
    }
  }

  Future<void> _onNextPage(
    JobSearchNextPageRequested event,
    Emitter<JobSearchResultsState> emit,
  ) async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;
    final id = _latest;
    emit(state.copyWith(isLoadingMore: true, errorMessage: () => null));
    final result = await _search(state.query, page: state.page + 1);
    if (id != _latest) return;
    switch (result) {
      case Ok(:final value):
        final seen = {for (final j in state.jobs) j.id};
        emit(
          state.copyWith(
            jobs: [...state.jobs, ...value.jobs.where((j) => seen.add(j.id))],
            page: value.page,
            total: value.total,
            hasMore: value.hasMore,
            isLoadingMore: false,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            isLoadingMore: false,
            errorMessage: () => failure.message,
          ),
        );
    }
  }
}
