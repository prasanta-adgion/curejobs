import 'package:equatable/equatable.dart';

import 'subscription_package.dart';

class CurrentSubscription extends Equatable {
  const CurrentSubscription({
    required this.id,
    required this.package,
    required this.status,
    required this.source,
    this.startsAt,
    this.expiresAt,
    this.autoRenew = false,
    this.cancelAtPeriodEnd = false,
    this.maxResumes,
    this.monthlyApplications,
    this.features = const {},
  });

  final String id;
  final SubscriptionPackage package;

  /// e.g. `ACTIVE`.
  final String status;

  /// e.g. `SYSTEM_FALLBACK`, `ADMIN_GRANT`, `CHECKOUT`.
  final String source;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final bool autoRenew;
  final bool cancelAtPeriodEnd;

  /// Effective limits (top-level `limits` in the response).
  final int? maxResumes;
  final int? monthlyApplications;

  /// Effective feature flags (top-level `features` in the response).
  final Map<String, bool> features;

  bool get isActive => status == 'ACTIVE';

  bool get isFree => package.isFree;

  bool has(String feature) => features[feature] ?? false;

  /// Whole days until [expiresAt]; null when there's no end date.
  int? daysLeft([DateTime? now]) {
    final end = expiresAt;
    if (end == null) return null;
    final diff = end.difference(now ?? DateTime.now());
    return diff.isNegative ? 0 : diff.inDays;
  }

  /// Paid plan ending within a week, so the UI can offer Renew.
  bool get isEndingSoon {
    final left = daysLeft();
    return !isFree && left != null && left <= 7;
  }

  @override
  List<Object?> get props => [
    id,
    package,
    status,
    expiresAt,
    maxResumes,
    monthlyApplications,
    features,
  ];
}
