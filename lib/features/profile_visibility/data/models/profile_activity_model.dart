import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/profile_activity.dart';

abstract final class ProfileActivityModel {
  /// Parses `{ "data": { items, total, lockedCount, isPro } }`.
  static ProfileActivity fromJson(Object? json) {
    final root = JsonParser.map(json);
    final data = root.containsKey('data') ? JsonParser.map(root['data']) : root;
    return ProfileActivity(
      items: JsonParser.list(data['items'])
          .map((e) => _item(JsonParser.map(e)))
          .toList(growable: false),
      total: JsonParser.integer(data['total']),
      lockedCount: JsonParser.integer(data['lockedCount']),
      isPro: JsonParser.boolean(data['isPro']),
    );
  }

  static ProfileActivityItem _item(Map<String, dynamic> j) {
    return ProfileActivityItem(
      id: JsonParser.string(j['id']),
      kind: JsonParser.string(j['kind']),
      organizationName: JsonParser.string(j['organizationName']),
      jobId: JsonParser.nullableString(j['jobId']),
      jobTitle: JsonParser.nullableString(j['jobTitle']),
      at: JsonParser.dateTime(j['at']),
    );
  }
}
