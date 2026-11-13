import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/job.dart';
import '../../domain/entities/job_feed.dart';
import '../../domain/usecases/get_jobs_usecase.dart';

part 'jobs_event.dart';
part 'jobs_state.dart';

/// Loads one [JobFeed] a page at a time. Use one bloc per feed.
class JobsBloc extends Bloc<JobsEvent, JobsState> {
  final GetJobsUseCase _getJobs;
  final JobFeed feed;

  JobsBloc(this._getJobs, {required this.feed}) : super(const JobsState()) {
    // Extra requests are ignored while one of the same kind is in flight.
    on<JobsRequested>(_onRequested);
    on<JobsNextPageRequested>(_onNextPage);
  }

  Future<void> _onRequested(
    JobsRequested event,
    Emitter<JobsState> emit,
  ) async {
    if (state.status == JobsStatus.loading) return;
    emit(state.copyWith(status: JobsStatus.loading, clearError: true));

    final result = await _getJobs(feed: feed, page: 1);

    result.fold(
      (page) => emit(
        JobsState(
          status: JobsStatus.success,
          jobs: page.jobs,
          page: page.page,
          total: page.total,
          hasMore: page.hasMore,
        ),
      ),
      (failure) => emit(
        state.copyWith(
          status: JobsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  Future<void> _onNextPage(
    JobsNextPageRequested event,
    Emitter<JobsState> emit,
  ) async {
    if (state.status != JobsStatus.success ||
        !state.hasMore ||
        state.isLoadingMore) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true, clearError: true));

    final result = await _getJobs(feed: feed, page: state.page + 1);

    result.fold(
      (page) => emit(
        state.copyWith(
          jobs: [...state.jobs, ...page.jobs],
          page: page.page,
          total: page.total,
          hasMore: page.hasMore,
          isLoadingMore: false,
        ),
      ),
      (failure) => emit(
        state.copyWith(isLoadingMore: false, errorMessage: failure.message),
      ),
    );
  }
}
