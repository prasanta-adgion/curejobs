part of 'jobs_bloc.dart';

enum JobsStatus { initial, loading, success, failure }

class JobsState extends Equatable {
  final JobsStatus status;

  /// Kept during a reload so the list doesn't blank out.
  final List<Job> jobs;
  final int page;
  final int total;
  final bool hasMore;
  final bool isLoadingMore;

  /// Set when the first page or a later page fails to load.
  final String? errorMessage;

  const JobsState({
    this.status = JobsStatus.initial,
    this.jobs = const [],
    this.page = 0,
    this.total = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  bool get isInitialLoading =>
      (status == JobsStatus.initial || status == JobsStatus.loading) &&
      jobs.isEmpty;

  JobsState copyWith({
    JobsStatus? status,
    List<Job>? jobs,
    int? page,
    int? total,
    bool? hasMore,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return JobsState(
      status: status ?? this.status,
      jobs: jobs ?? this.jobs,
      page: page ?? this.page,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    jobs,
    page,
    total,
    hasMore,
    isLoadingMore,
    errorMessage,
  ];
}
