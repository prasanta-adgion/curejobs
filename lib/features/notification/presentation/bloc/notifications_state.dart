part of 'notifications_bloc.dart';

enum NotificationsStatus { initial, loading, success, failure }

/// Filter chips, in display order.
enum NotificationFilter {
  all('All'),
  unread('Unread'),
  applications('Applications'),
  jobs('Jobs'),
  account('Account');

  const NotificationFilter(this.label);

  final String label;

  /// Sent as `category`; null for All and Unread.
  NotificationCategory? get category => switch (this) {
    applications => NotificationCategory.applications,
    jobs => NotificationCategory.jobs,
    account => NotificationCategory.system,
    _ => null,
  };

  int countIn(NotificationSummary s) => switch (this) {
    all => s.total,
    unread => s.unread,
    _ => s.countOf(category!),
  };
}

/// A mark-read request failed and was rolled back; shown once as a snackbar.
class MarkReadFailure extends Equatable {
  const MarkReadFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [identityHashCode(this)];
}

class NotificationsState extends Equatable {
  const NotificationsState({
    this.markReadFailure,
    this.status = NotificationsStatus.initial,
    this.items = const [],
    this.summary = const NotificationSummary(),
    this.filter = NotificationFilter.all,
    this.page = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isFiltering = false,
    this.failure,
  });

  final NotificationsStatus status;
  final List<AppNotification> items;
  final NotificationSummary summary;
  final NotificationFilter filter;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  /// A filter change is loading its first page.
  final bool isFiltering;
  final Failure? failure;
  final MarkReadFailure? markReadFailure;

  bool get isLoading =>
      status == NotificationsStatus.initial ||
      status == NotificationsStatus.loading;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<AppNotification>? items,
    NotificationSummary? summary,
    NotificationFilter? filter,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isFiltering,
    Failure? Function()? failure,
    MarkReadFailure? Function()? markReadFailure,
  }) {
    return NotificationsState(
      markReadFailure: markReadFailure != null
          ? markReadFailure()
          : this.markReadFailure,
      status: status ?? this.status,
      items: items ?? this.items,
      summary: summary ?? this.summary,
      filter: filter ?? this.filter,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isFiltering: isFiltering ?? this.isFiltering,
      failure: failure != null ? failure() : this.failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    summary,
    filter,
    page,
    hasMore,
    isLoadingMore,
    isFiltering,
    failure,
    markReadFailure,
  ];
}
