import '../../../../core/result/result.dart';
import '../repositories/notification_repository.dart';

/// Marks one notification as read.
class MarkNotificationReadUseCase {
  final NotificationRepository _repository;

  const MarkNotificationReadUseCase(this._repository);

  Future<Result<void>> call(String notificationId) =>
      _repository.markRead(notificationId);
}

/// Marks every notification as read.
class MarkAllNotificationsReadUseCase {
  final NotificationRepository _repository;

  const MarkAllNotificationsReadUseCase(this._repository);

  Future<Result<void>> call() => _repository.markAllRead();
}
