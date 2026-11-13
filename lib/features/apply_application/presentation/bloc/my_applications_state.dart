part of 'my_applications_bloc.dart';

enum MyApplicationsStatus { initial, loading, success, failure }

/// Outcome of the latest withdraw, for a one-off snackbar.
class WithdrawResult extends Equatable {
  const WithdrawResult.done(this.application) : failure = null;
  const WithdrawResult.failed(this.application, Failure this.failure);

  final JobApplication application;
  final Failure? failure;

  bool get isSuccess => failure == null;

  @override
  List<Object?> get props => [identityHashCode(this)];
}

class MyApplicationsState extends Equatable {
  const MyApplicationsState({
    this.status = MyApplicationsStatus.initial,
    this.items = const [],
    this.counts = const {},
    this.page = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isFiltering = false,
    this.filter,
    this.failure,
    this.withdrawingIds = const {},
    this.withdrawResult,
  });

  final MyApplicationsStatus status;

  /// Items for the current [filter], as returned by the API.
  final List<JobApplication> items;

  /// Totals per status across every page and status.
  final Map<ApplicationStatus, int> counts;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  /// A filter change is loading its first page.
  final bool isFiltering;

  /// Status sent to the API; null means "All".
  final ApplicationStatus? filter;
  final Failure? failure;

  /// Applications with a withdraw request in flight.
  final Set<String> withdrawingIds;
  final WithdrawResult? withdrawResult;

  bool get isLoading =>
      status == MyApplicationsStatus.initial ||
      status == MyApplicationsStatus.loading;

  int countOf(ApplicationStatus s) => counts[s] ?? 0;

  int get totalCount => counts.values.fold(0, (sum, n) => sum + n);

  /// For "All", active applications go first (API order kept within each).
  List<JobApplication> get visibleItems {
    if (filter != null) return items;
    return [
      ...items.where((a) => a.status.isActive),
      ...items.where((a) => !a.status.isActive),
    ];
  }

  MyApplicationsState copyWith({
    MyApplicationsStatus? status,
    List<JobApplication>? items,
    Map<ApplicationStatus, int>? counts,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isFiltering,
    ApplicationStatus? Function()? filter,
    Failure? Function()? failure,
    Set<String>? withdrawingIds,
    WithdrawResult? Function()? withdrawResult,
  }) {
    return MyApplicationsState(
      status: status ?? this.status,
      items: items ?? this.items,
      counts: counts ?? this.counts,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isFiltering: isFiltering ?? this.isFiltering,
      filter: filter != null ? filter() : this.filter,
      failure: failure != null ? failure() : this.failure,
      withdrawingIds: withdrawingIds ?? this.withdrawingIds,
      withdrawResult: withdrawResult != null
          ? withdrawResult()
          : this.withdrawResult,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    counts,
    page,
    hasMore,
    isLoadingMore,
    isFiltering,
    filter,
    failure,
    withdrawingIds,
    withdrawResult,
  ];
}
