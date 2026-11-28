import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/package_request.dart';

abstract final class PackageRequestModel {
  /// Parses the full response body (`{ "data": [ ... ] }`) or a bare list.
  static List<PackageRequest> listFromJson(Object? json) {
    final items = json is Map
        ? JsonParser.list(JsonParser.map(json)['data'])
        : JsonParser.list(json);
    return [
      for (final item in items)
        if (item is Map<String, dynamic>) fromJson(item),
    ]..sort(_newestFirst);
  }

  static PackageRequest fromJson(Map<String, dynamic> json) {
    final pkg = json['package'];
    final package = pkg is Map<String, dynamic> ? _package(pkg) : null;
    return PackageRequest(
      id: JsonParser.string(json['id']),
      packageId: JsonParser.string(
        json['packageId'],
        fallback: package?.id ?? '',
      ),
      status: PackageRequestStatusType.fromApi(
        JsonParser.string(json['status']),
      ),
      message: _text(json['message']),
      reviewReason: _text(json['reviewReason']),
      subscriptionId: _text(json['subscriptionId']),
      createdAt: JsonParser.dateTime(json['createdAt']),
      reviewedAt: JsonParser.dateTime(json['reviewedAt']),
      updatedAt: JsonParser.dateTime(json['updatedAt']),
      package: package,
    );
  }

  static RequestedPackage _package(Map<String, dynamic> json) =>
      RequestedPackage(
        id: JsonParser.string(json['id']),
        code: JsonParser.string(json['code']),
        name: JsonParser.string(json['name']),
        description: JsonParser.string(json['description']),
        type: JsonParser.string(json['type']),
        durationDays: JsonParser.integer(json['durationDays']),
        priceMinor: JsonParser.integer(json['priceMinor']),
        currency: JsonParser.string(json['currency'], fallback: 'INR'),
      );

  /// Null for missing or blank strings.
  static String? _text(Object? value) {
    final s = JsonParser.nullableString(value)?.trim();
    return (s == null || s.isEmpty) ? null : s;
  }

  static int _newestFirst(PackageRequest a, PackageRequest b) {
    final at = a.createdAt, bt = b.createdAt;
    if (at == null && bt == null) return 0;
    if (at == null) return 1;
    if (bt == null) return -1;
    return bt.compareTo(at);
  }
}
