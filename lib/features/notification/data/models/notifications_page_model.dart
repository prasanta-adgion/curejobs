import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/app_notification.dart';

/// Parses `GET api/v1/notifications`:
/// `{ data: [...], summary: {...}, pagination: {...} }`.
abstract final class NotificationsPageModel {
  static NotificationsPage fromJson(Object? json) {
    final root = JsonParser.map(json);
    final summary = JsonParser.map(root['summary']);
    final pagination = JsonParser.map(root['pagination']);

    return NotificationsPage(
      items: [
        for (final item in JsonParser.list(root['data']))
          if (item is Map<String, dynamic>) _item(item),
      ],
      summary: NotificationSummary(
        total: JsonParser.integer(summary['total']),
        unread: JsonParser.integer(summary['unread']),
        applications: JsonParser.integer(summary['applications']),
        jobs: JsonParser.integer(summary['jobs']),
        system: JsonParser.integer(summary['system']),
      ),
      page: JsonParser.integer(pagination['page'], fallback: 1),
      hasMore: JsonParser.boolean(pagination['hasMore']),
    );
  }

  static AppNotification _item(Map<String, dynamic> json) => AppNotification(
    id: JsonParser.string(json['id']),
    type: NotificationType.fromApi(JsonParser.string(json['type'])),
    category: NotificationCategory.fromApi(JsonParser.string(json['category'])),
    subject: JsonParser.string(json['subject'], fallback: 'Notification'),
    createdAt:
        JsonParser.dateTime(json['createdAt'])?.toLocal() ?? DateTime.now(),
    readAt: JsonParser.dateTime(json['readAt'])?.toLocal(),
    payload: JsonParser.map(json['payloadJson']),
  );
}
