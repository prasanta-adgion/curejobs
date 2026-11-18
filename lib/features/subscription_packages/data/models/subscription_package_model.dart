import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/subscription_package.dart';

abstract final class SubscriptionPackageModel {
  /// Parses the full response body (`{ "data": [ ... ] }`).
  static List<SubscriptionPackage> listFromJson(Object? json) {
    final items = json is Map
        ? JsonParser.list(JsonParser.map(json)['data'])
        : JsonParser.list(json);
    return [
      for (final item in items)
        if (item is Map<String, dynamic>) fromJson(item),
    ];
  }

  static SubscriptionPackage fromJson(Map<String, dynamic> json) {
    final limits = JsonParser.map(json['limitsJson']);
    final features = JsonParser.map(json['featuresJson']);
    return SubscriptionPackage(
      id: JsonParser.string(json['id']),
      code: JsonParser.string(json['code']),
      name: JsonParser.string(json['name']),
      description: JsonParser.string(json['description']),
      priceMinor: JsonParser.integer(json['priceMinor']),
      currency: JsonParser.string(json['currency'], fallback: 'INR'),
      durationDays: JsonParser.integer(json['durationDays']),
      maxResumes: JsonParser.nullableInteger(limits['maxResumes']),
      monthlyApplications: JsonParser.nullableInteger(
        limits['monthlyApplications'],
      ),
      features: {
        for (final e in features.entries) e.key: JsonParser.boolean(e.value),
      },
      freeSelectionEnabled: JsonParser.boolean(json['freeSelectionEnabled']),
      paidCheckoutEnabled: JsonParser.boolean(json['paidCheckoutEnabled']),
      purchaseAvailable: JsonParser.boolean(json['purchaseAvailable']),
      billingOptions: [
        for (final o in JsonParser.list(json['billingOptions']))
          if (o is Map<String, dynamic>) _billing(o),
      ],
    );
  }

  static BillingOption _billing(Map<String, dynamic> json) => BillingOption(
    id: JsonParser.string(json['id']),
    billingPeriod: JsonParser.string(json['billingPeriod']),
    interval: JsonParser.integer(json['interval']),
    durationDays: JsonParser.integer(json['durationDays']),
    amountMinor: JsonParser.integer(json['amountMinor']),
    currency: JsonParser.string(json['currency'], fallback: 'INR'),
    purchaseAvailable: JsonParser.boolean(json['purchaseAvailable']),
  );
}
