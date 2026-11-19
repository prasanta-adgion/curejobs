import '../../../../core/result/result.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remote;

  const NotificationRepositoryImpl(this._remote);

  @override
  Future<Result<int>> getUnreadCount() =>
      Result.guard(() => _remote.getUnreadCount());

  @override
  Future<Result<NotificationsPage>> getNotifications({
    required int page,
    required int limit,
    bool unreadOnly = false,
    NotificationCategory? category,
  }) {
    return Result.guard(
      () => _remote.getNotifications(
        page: page,
        limit: limit,
        unreadOnly: unreadOnly,
        category: category?.apiValue,
      ),
    );
  }

  @override
  Future<Result<void>> markRead(String notificationId) =>
      Result.guard(() => _remote.markRead(notificationId));

  @override
  Future<Result<void>> markAllRead() =>
      Result.guard(() => _remote.markAllRead());
}
