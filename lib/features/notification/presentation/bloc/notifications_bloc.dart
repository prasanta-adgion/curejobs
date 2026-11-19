import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc(this._getNotifications, this._markRead, this._markAllRead)
    : super(const NotificationsState()) {
    on<NotificationsRequested>(_onRequested);
    on<NotificationsRefreshed>(_onRefreshed);
    on<NotificationsNextPageRequested>(_onNextPage);
    on<NotificationsFilterChanged>(_onFilterChanged);
    on<NotificationMarkedRead>(_onMarkedRead);
    on<NotificationsAllMarkedRead>(_onAllMarkedRead);
  }

  final GetNotificationsUseCase _getNotifications;
  final MarkNotificationReadUseCase _markRead;
  final MarkAllNotificationsReadUseCase _markAllRead;

  static const _pageSize = 20;

  Future<void> _onRequested(
    NotificationsRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    await _loadFirstPage(emit);
  }

  Future<void> _onRefreshed(
    NotificationsRefreshed event,
    Emitter<NotificationsState> emit,
  ) => _loadFirstPage(emit);

  Future<void> _onFilterChanged(
    NotificationsFilterChanged event,
    Emitter<NotificationsState> emit,
  ) async {
    if (event.filter == state.filter) return;
    emit(
      state.copyWith(
        filter: event.filter,
        isFiltering: true,
        items: const [],
        hasMore: false,
      ),
    );
    await _loadFirstPage(emit);
  }

  Future<NotificationsPage?> _fetch(
    Emitter<NotificationsState> emit,
    int page,
  ) async {
    final filter = state.filter;
    final result = await _getNotifications(
      page: page,
      limit: _pageSize,
      unreadOnly: filter == NotificationFilter.unread,
      category: filter.category,
    );
    // The user picked another filter while this request was running.
    if (filter != state.filter) return null;

    return result.fold((page) => page, (failure) {
      emit(
        state.copyWith(
          status: state.status == NotificationsStatus.success
              ? NotificationsStatus.success
              : NotificationsStatus.failure,
          isFiltering: false,
          isLoadingMore: false,
          failure: () => failure,
        ),
      );
      return null;
    });
  }

  Future<void> _loadFirstPage(Emitter<NotificationsState> emit) async {
    final page = await _fetch(emit, 1);
    if (page == null) return;
    emit(
      state.copyWith(
        status: NotificationsStatus.success,
        isFiltering: false,
        items: page.items,
        summary: _summaryFrom(page),
        page: page.page,
        hasMore: page.hasMore,
        failure: () => null,
      ),
    );
  }

  Future<void> _onNextPage(
    NotificationsNextPageRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    if (!state.hasMore ||
        state.isLoadingMore ||
        state.isLoading ||
        state.isFiltering) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    final page = await _fetch(emit, state.page + 1);
    if (page == null) return;

    final seen = state.items.map((n) => n.id).toSet();
    emit(
      state.copyWith(
        isLoadingMore: false,
        items: [
          ...state.items,
          ...page.items.where((n) => !seen.contains(n.id)),
        ],
        summary: _summaryFrom(page),
        page: page.page,
        hasMore: page.hasMore,
      ),
    );
  }

  /// Chip counts are totals across all categories. If a filtered response
  /// returns a scoped summary, keep the totals we already have.
  NotificationSummary _summaryFrom(NotificationsPage page) {
    if (state.filter == NotificationFilter.all ||
        state.summary.total == 0 ||
        page.summary.total >= state.summary.total) {
      return page.summary;
    }
    return state.summary.copyWith(unread: page.summary.unread);
  }

  /// Updates the row straight away, then tells the server. On failure the
  /// row and count go back to how they were.
  Future<void> _onMarkedRead(
    NotificationMarkedRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final index = state.items.indexWhere((n) => n.id == event.id && n.isUnread);
    if (index < 0) return;

    final previousItems = state.items;
    final previousSummary = state.summary;
    final items = [...state.items]..[index] = state.items[index].markRead();
    final unread = previousSummary.unread > 0 ? previousSummary.unread - 1 : 0;
    emit(
      state.copyWith(
        items: state.filter == NotificationFilter.unread
            ? items.where((n) => n.isUnread).toList()
            : items,
        summary: previousSummary.copyWith(unread: unread),
      ),
    );

    final result = await _markRead(event.id);
    if (result.failureOrNull case final failure?) {
      emit(
        state.copyWith(
          items: _restore(previousItems, [event.id]),
          summary: state.summary.copyWith(unread: state.summary.unread + 1),
          markReadFailure: () => MarkReadFailure(failure),
        ),
      );
    }
  }

  Future<void> _onAllMarkedRead(
    NotificationsAllMarkedRead event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state.summary.unread == 0 && !state.items.any((n) => n.isUnread)) {
      return;
    }
    final previousItems = state.items;
    final previousSummary = state.summary;
    final wereUnread = [
      for (final n in previousItems)
        if (n.isUnread) n.id,
    ];
    final now = DateTime.now();
    emit(
      state.copyWith(
        items: state.filter == NotificationFilter.unread
            ? const []
            : [for (final n in previousItems) n.markRead(now)],
        summary: previousSummary.copyWith(unread: 0),
      ),
    );

    final result = await _markAllRead();
    if (result.failureOrNull case final failure?) {
      emit(
        state.copyWith(
          items: _restore(previousItems, wereUnread),
          summary: state.summary.copyWith(unread: previousSummary.unread),
          markReadFailure: () => MarkReadFailure(failure),
        ),
      );
    }
  }

  /// Puts [ids] back to unread, keeping any other changes (e.g. a page
  /// that loaded while the request was running).
  List<AppNotification> _restore(
    List<AppNotification> previous,
    List<String> ids,
  ) {
    final originals = {
      for (final n in previous)
        if (ids.contains(n.id)) n.id: n,
    };
    // Rows dropped from the Unread filter come back from [previous].
    if (state.filter == NotificationFilter.unread) {
      final current = {for (final n in state.items) n.id: n};
      return [for (final n in previous) current[n.id] ?? originals[n.id] ?? n];
    }
    return [for (final n in state.items) originals[n.id] ?? n];
  }
}
