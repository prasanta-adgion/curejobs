import 'package:equatable/equatable.dart';

import 'subscription_package.dart';

class CurrentSubscription extends Equatable {
  const CurrentSubscription({
    required this.id,
    required this.package,
    required this.status,
    required this.source,
    this.packageId,
    this.providerSubscriptionId,
    this.startsAt,
    this.expiresAt,
    this.activatedAt,
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

  /// e.g. `SYSTEM_FALLBACK`, `ADMIN_GRANT`, `PAID_PURCHASE`.
  final String source;
  final String? packageId;

  /// Payment provider's id, e.g. `sub_...`; null for free plans.
  final String? providerSubscriptionId;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final DateTime? activatedAt;
  final bool autoRenew;
  final bool cancelAtPeriodEnd;

  /// Effective limits (top-level `limits` in the response).
  final int? maxResumes;
  final int? monthlyApplications;

  /// Effective feature flags (`subscription.featuresSnapshotJson`).
  final Map<String, bool> features;

  bool get isActive => status == 'ACTIVE';
  bool get isSelectedPlan => isActive && source != 'SYSTEM_FALLBACK';

  /// A plan the user paid for, so the auto-pay row is shown.
  bool get isPaidPurchase => isActive && !isFree && source == 'PAID_PURCHASE';

  /// Will be charged again on [expiresAt].
  bool get isAutoPayOn => autoRenew && !cancelAtPeriodEnd;

  bool get canCancelAutoRenew =>
      isActive &&
      !isFree &&
      source == 'PAID_PURCHASE' &&
      autoRenew &&
      !cancelAtPeriodEnd &&
      id.isNotEmpty &&
      (providerSubscriptionId?.isNotEmpty ?? false);

  bool get isFree => package.isFree;

  /// Users on an active paid plan can't move down to a free plan.
  bool canSwitchTo(SubscriptionPackage target) =>
      !(target.isFree && isActive && !isFree);

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
    source,
    providerSubscriptionId,
    autoRenew,
    cancelAtPeriodEnd,
    expiresAt,
    maxResumes,
    monthlyApplications,
    features,
  ];
}
