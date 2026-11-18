import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/entities/plan_history_entry.dart';

abstract final class PaymentRecordModel {
  /// Parses `{ "data": [ { payment, purchase, package }, ... ] }`.
  static List<PaymentRecord> listFromJson(Object? json) {
    final root = JsonParser.map(json);
    return [
      for (final item in JsonParser.list(root['data']))
        if (item is Map<String, dynamic>) fromJson(item),
    ];
  }

  static PaymentRecord fromJson(Map<String, dynamic> json) {
    final payment = JsonParser.map(json['payment']);
    final purchase = JsonParser.map(json['purchase']);
    final package = JsonParser.map(json['package']);
    return PaymentRecord(
      id: JsonParser.string(payment['id']),
      status: PaymentStatus.fromApi(JsonParser.string(payment['status'])),
      amountMinor: JsonParser.integer(payment['amountMinor']),
      currency: JsonParser.string(payment['currency'], fallback: 'INR'),
      providerPaymentId: JsonParser.nullableString(
        payment['providerPaymentId'],
      ),
      paidAt: JsonParser.dateTime(payment['paidAt']),
      createdAt: JsonParser.dateTime(payment['createdAt']) ?? DateTime.now(),
      purchaseStatus: JsonParser.string(purchase['status']),
      packageId: JsonParser.string(package['id']),
      packageName: JsonParser.string(package['name']),
      durationDays: JsonParser.integer(package['durationDays']),
    );
  }
}

abstract final class PlanHistoryModel {
  /// Parses `{ "data": [ ... ], "meta": { page, limit, total, totalPages } }`.
  static PlanHistoryPage pageFromJson(Object? json) {
    final root = JsonParser.map(json);
    final meta = JsonParser.map(root['meta']);
    final items = [
      for (final item in JsonParser.list(root['data']))
        if (item is Map<String, dynamic>) fromJson(item),
    ];
    return PlanHistoryPage(
      items: items,
      page: JsonParser.integer(meta['page'], fallback: 1),
      totalPages: JsonParser.integer(meta['totalPages'], fallback: 1),
      total: JsonParser.integer(meta['total'], fallback: items.length),
    );
  }

  static PlanHistoryEntry fromJson(Map<String, dynamic> json) {
    final limits = JsonParser.map(json['limitsSnapshotJson']);
    final features = JsonParser.map(json['featuresSnapshotJson']);
    return PlanHistoryEntry(
      id: JsonParser.string(json['id']),
      packageId: JsonParser.string(json['packageId']),
      packageName: JsonParser.string(json['packageName']),
      packageCode: JsonParser.string(json['packageCode']),
      durationDays: JsonParser.integer(json['packageDurationDays']),
      status: PlanHistoryStatus.fromApi(JsonParser.string(json['status'])),
      source: PlanSource.fromApi(JsonParser.string(json['source'])),
      startsAt: JsonParser.dateTime(json['startsAt']),
      expiresAt: JsonParser.dateTime(json['expiresAt']),
      cancelledAt: JsonParser.dateTime(json['cancelledAt']),
      maxResumes: JsonParser.nullableInteger(limits['maxResumes']),
      monthlyApplications: JsonParser.nullableInteger(
        limits['monthlyApplications'],
      ),
      features: {
        for (final e in features.entries) e.key: JsonParser.boolean(e.value),
      },
    );
  }
}
