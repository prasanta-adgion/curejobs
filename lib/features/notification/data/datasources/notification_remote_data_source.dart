import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/app_notification.dart';
import '../models/notifications_page_model.dart';

abstract interface class NotificationRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<int> getUnreadCount();

  /// Throws a `Failure` on error. [category] is the API value
  /// (`APPLICATIONS`, `JOBS`, `SYSTEM`); null returns all.
  Future<NotificationsPage> getNotifications({
    required int page,
    required int limit,
    bool unreadOnly = false,
    String? category,
  });

  /// Throws a `Failure` on error.
  Future<void> markRead(String notificationId);

  /// Throws a `Failure` on error.
  Future<void> markAllRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient _client;

  const NotificationRemoteDataSourceImpl(this._client);

  @override
  Future<int> getUnreadCount() {
    return _client.get<int>(
      ApiEndpoints.unreadNotificationCount,
      decoder: _parseUnreadCount,
    );
  }

  @override
  Future<NotificationsPage> getNotifications({
    required int page,
    required int limit,
    bool unreadOnly = false,
    String? category,
  }) {
    return _client.get<NotificationsPage>(
      ApiEndpoints.allNotifications,
      queryParameters: {
        'page': page,
        'limit': limit,
        'unreadOnly': unreadOnly,
        'category': ?category,
      },
      decoder: NotificationsPageModel.fromJson,
    );
  }

  @override
  Future<void> markRead(String notificationId) {
    return _client.post<void>(
      ApiEndpoints.markNotificationsRead(notificationId: notificationId),
    );
  }

  @override
  Future<void> markAllRead() {
    return _client.post<void>(ApiEndpoints.markAllNotificationsRead);
  }

  /// Parses `{ "data": { "unreadCount": 1 } }`.
  static int _parseUnreadCount(Object? json) {
    final root = JsonParser.map(json);
    final data = root.containsKey('data') ? JsonParser.map(root['data']) : root;
    return JsonParser.integer(data['unreadCount']);
  }
}
