import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_unread_notification_count_usecase.dart';

/// App-wide unread notification count. Shared (lazy singleton) so the
/// notifications screen can update the dashboard badge when items are
/// marked as read.
class UnreadNotificationCountCubit extends Cubit<int> {
  UnreadNotificationCountCubit(this._getUnreadCount) : super(0);

  final GetUnreadNotificationCountUseCase _getUnreadCount;

  /// Fetches the count from the server. Keeps the current value on failure.
  Future<void> load() async {
    final result = await _getUnreadCount();
    final count = result.valueOrNull;
    if (count != null && !isClosed) emit(count < 0 ? 0 : count);
  }

  /// Call after a single notification is marked as read.
  void markOneRead() {
    if (state > 0) emit(state - 1);
  }

  /// Call after "mark all as read" succeeds.
  void markAllRead() => emit(0);

  /// Sets the count directly, e.g. from a push or a list response.
  void setCount(int count) => emit(count < 0 ? 0 : count);
}
