part of 'job_search_results_bloc.dart';

enum JobSearchResultsStatus { initial, loading, success, failure }

final class JobSearchResultsState extends Equatable {
  const JobSearchResultsState({
    this.status = JobSearchResultsStatus.initial,
    this.query = const SearchQuery(),
    this.jobs = const [],
    this.page = 0,
    this.total = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final JobSearchResultsStatus status;
  final SearchQuery query;
  final List<Job> jobs;

  /// Last page loaded.
  final int page;
  final int total;
  final bool hasMore;
  final bool isLoadingMore;

  /// First-page error, or a next-page error while [jobs] stay on screen.
  final String? errorMessage;

  bool get isLoading => status == JobSearchResultsStatus.loading;

  JobSearchResultsState copyWith({
    JobSearchResultsStatus? status,
    List<Job>? jobs,
    int? page,
    int? total,
    bool? hasMore,
    bool? isLoadingMore,
    String? Function()? errorMessage,
  }) => JobSearchResultsState(
    status: status ?? this.status,
    query: query,
    jobs: jobs ?? this.jobs,
    page: page ?? this.page,
    total: total ?? this.total,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
  );

  @override
  List<Object?> get props => [
    status,
    query,
    jobs,
    page,
    total,
    hasMore,
    isLoadingMore,
    errorMessage,
  ];
}
