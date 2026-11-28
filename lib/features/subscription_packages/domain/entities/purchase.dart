import 'package:equatable/equatable.dart';

/// A purchase created by `POST purchases`. Starts as `PENDING`.
class Purchase extends Equatable {
  const Purchase({
    required this.id,
    required this.packageId,
    required this.status,
    required this.amountMinor,
    required this.currency,
    this.providerSubscriptionId,
  });

  final String id;
  final String packageId;
  final String status;
  final int amountMinor;
  final String currency;
  final String? providerSubscriptionId;

  bool get isPaid => status.toUpperCase() == 'PAID';
  bool get isUnsuccessful =>
      const {'FAILED', 'CANCELLED', 'EXPIRED'}.contains(status.toUpperCase());

  @override
  List<Object?> get props => [id, status, providerSubscriptionId];
}

/// What the Razorpay checkout needs to open for a subscription.
class RazorpayCheckout extends Equatable {
  const RazorpayCheckout({
    required this.purchaseId,
    required this.keyId,
    required this.subscriptionId,
    required this.name,
    required this.description,
    required this.amountMinor,
    required this.currency,
  });

  final String purchaseId;
  final String keyId;
  final String subscriptionId;
  final String name;
  final String description;
  final int amountMinor;
  final String currency;

  @override
  List<Object?> get props => [purchaseId, subscriptionId];
}

/// Result of `POST payments/razorpay/verify`.
class PaymentVerification extends Equatable {
  const PaymentVerification({
    required this.purchaseId,
    required this.status,
    this.subscriptionId,
  });

  final String purchaseId;

  /// Our subscription id (not Razorpay's).
  final String? subscriptionId;

  /// e.g. `ACTIVE`.
  final String status;

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  @override
  List<Object?> get props => [purchaseId, subscriptionId, status];
}
