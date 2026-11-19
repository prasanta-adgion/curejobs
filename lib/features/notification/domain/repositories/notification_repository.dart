import '../../../../core/result/result.dart';
import '../entities/app_notification.dart';

abstract interface class NotificationRepository {
  Future<Result<int>> getUnreadCount();

  /// [category] null returns every category.
  Future<Result<NotificationsPage>> getNotifications({
    required int page,
    required int limit,
    bool unreadOnly = false,
    NotificationCategory? category,
  });

  Future<Result<void>> markRead(String notificationId);

  Future<Result<void>> markAllRead();
}
