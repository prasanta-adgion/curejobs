import '../../../../core/result/result.dart';
import '../entities/app_notification.dart';
import '../repositories/notification_repository.dart';

/// One page of the candidate's notifications.
class GetNotificationsUseCase {
  final NotificationRepository _repository;

  const GetNotificationsUseCase(this._repository);

  Future<Result<NotificationsPage>> call({
    required int page,
    required int limit,
    bool unreadOnly = false,
    NotificationCategory? category,
  }) => _repository.getNotifications(
    page: page,
    limit: limit,
    unreadOnly: unreadOnly,
    category: category,
  );
}
