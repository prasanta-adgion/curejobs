part of 'plan_purchase_bloc.dart';

/// One paid checkout attempt. Kept by the bloc so a retry for the same
/// billing option reuses the idempotency key and purchase.
class _PurchaseAttempt {
  _PurchaseAttempt({
    required this.billingOptionId,
    required this.packageId,
    required this.idempotencyKey,
  }) : startedAt = DateTime.now();

  final String billingOptionId;
  final String packageId;
  final String idempotencyKey;
  final DateTime startedAt;

  /// Filled after step 1 (`createPurchase`).
  String? purchaseId;

  /// Razorpay subscription id, filled after step 2.
  String? subscriptionId;

  /// The server's current plan is the one this attempt bought.
  bool isActivatedBy(CurrentSubscription sub) {
    if (!sub.isActive) return false;
    final subId = subscriptionId;
    if (subId != null && sub.providerSubscriptionId == subId) return true;
    // Fallback when the provider id isn't exposed: same package, activated
    // after this attempt started (allowing for clock skew).
    final activated = sub.activatedAt;
    return sub.package.id == packageId &&
        activated != null &&
        activated.isAfter(startedAt.subtract(const Duration(minutes: 5)));
  }
}
