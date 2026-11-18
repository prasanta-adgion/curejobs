part of 'plan_history_bloc.dart';

enum PlanHistoryStatus { loading, success, failure }

class PlanHistoryState extends Equatable {
  const PlanHistoryState({
    this.status = PlanHistoryStatus.loading,
    this.items = const [],
    this.page = 0,
    this.hasMore = false,
    this.total = 0,
    this.isLoadingMore = false,
    this.failure,
    this.loadMoreFailure,
  });

  final PlanHistoryStatus status;

  /// Every row loaded so far, in API order (newest first).
  final List<PlanHistoryEntry> items;
  final int page;
  final bool hasMore;
  final int total;
  final bool isLoadingMore;
  final Failure? failure;

  /// Set when the next page failed; the footer offers a retry.
  final Failure? loadMoreFailure;

  PlanHistoryEntry? get current {
    for (final e in items) {
      if (e.isActive) return e;
    }
    return null;
  }

  List<PlanHistoryEntry> get past => items.where((e) => !e.isActive).toList();

  /// Past rows across all pages (total minus the active one).
  int get pastTotal => current == null ? total : total - 1;

  PlanHistoryState copyWith({
    PlanHistoryStatus? status,
    List<PlanHistoryEntry>? items,
    int? page,
    bool? hasMore,
    int? total,
    bool? isLoadingMore,
    Failure? failure,
    Failure? loadMoreFailure,
    bool clearLoadMoreFailure = false,
  }) {
    return PlanHistoryState(
      status: status ?? this.status,
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      failure: failure ?? this.failure,
      loadMoreFailure: clearLoadMoreFailure
          ? null
          : loadMoreFailure ?? this.loadMoreFailure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    page,
    hasMore,
    total,
    isLoadingMore,
    failure,
    loadMoreFailure,
  ];
}
