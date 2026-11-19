import '../../../../core/result/result.dart';
import '../repositories/notification_repository.dart';

/// Number of notifications the candidate hasn't read yet.
class GetUnreadNotificationCountUseCase {
  final NotificationRepository _repository;

  const GetUnreadNotificationCountUseCase(this._repository);

  Future<Result<int>> call() => _repository.getUnreadCount();
}
