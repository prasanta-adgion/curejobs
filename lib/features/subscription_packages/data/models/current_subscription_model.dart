import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/current_subscription.dart';
import 'subscription_package_model.dart';

abstract final class CurrentSubscriptionModel {
  /// Parses the full response body
  /// (`{ "data": { package, subscription, features, limits } }`).
  static CurrentSubscription fromJson(Object? json) {
    final root = JsonParser.map(json);
    final data = root.containsKey('data') ? JsonParser.map(root['data']) : root;
    final sub = JsonParser.map(data['subscription']);
    final package = SubscriptionPackageModel.fromJson(
      JsonParser.map(data['package']),
    );

    // The subscription snapshot is the source of truth: when the admin adds or
    // changes features/limits they land in the snapshot. Fall back to the
    // top-level values, then the package's own defaults.
    final limits = _firstNonEmpty([
      JsonParser.map(sub['limitsSnapshotJson']),
      JsonParser.map(data['limits']),
    ]);
    final features = _firstNonEmpty([
      JsonParser.map(sub['featuresSnapshotJson']),
      JsonParser.map(data['features']),
    ]);

    return CurrentSubscription(
      id: JsonParser.string(sub['id']),
      package: package,
      status: JsonParser.string(sub['status']),
      source: JsonParser.string(sub['source']),
      packageId: JsonParser.nullableString(sub['packageId']),
      providerSubscriptionId: JsonParser.nullableString(
        sub['providerSubscriptionId'],
      ),
      startsAt: JsonParser.dateTime(sub['startsAt']),
      expiresAt: JsonParser.dateTime(sub['expiresAt']),
      activatedAt: JsonParser.dateTime(sub['activatedAt']),
      autoRenew: JsonParser.boolean(sub['autoRenew']),
      cancelAtPeriodEnd: JsonParser.boolean(sub['cancelAtPeriodEnd']),
      maxResumes:
          JsonParser.nullableInteger(limits?['maxResumes']) ??
          package.maxResumes,
      monthlyApplications:
          JsonParser.nullableInteger(limits?['monthlyApplications']) ??
          package.monthlyApplications,
      features: features == null
          ? package.features
          : {
              for (final e in features.entries)
                e.key: JsonParser.boolean(e.value),
            },
    );
  }

  static Map<String, dynamic>? _firstNonEmpty(List<Map<String, dynamic>> maps) {
    for (final m in maps) {
      if (m.isNotEmpty) return m;
    }
    return null;
  }
}
