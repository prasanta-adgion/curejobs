part of 'plan_purchase_bloc.dart';

sealed class PlanPurchaseEvent extends Equatable {
  const PlanPurchaseEvent();

  @override
  List<Object?> get props => [];
}

/// "Continue with …" tapped on a FREE plan: select it straight away.
final class FreePlanSelected extends PlanPurchaseEvent {
  const FreePlanSelected(this.package);

  final SubscriptionPackage package;

  @override
  List<Object?> get props => [package.id];
}

/// "Upgrade to …" tapped on a PAID plan: create the purchase + Razorpay
/// subscription, then open checkout.
final class PlanPurchaseStarted extends PlanPurchaseEvent {
  const PlanPurchaseStarted(this.package);

  final SubscriptionPackage package;

  @override
  List<Object?> get props => [package.id];
}

/// The page has opened the Razorpay checkout.
final class PlanCheckoutOpened extends PlanPurchaseEvent {
  const PlanCheckoutOpened();
}

/// Razorpay reported success. Not trusted: the server verifies the signature.
final class PlanPaymentSucceeded extends PlanPurchaseEvent {
  const PlanPaymentSucceeded({
    this.paymentId,
    this.subscriptionId,
    this.signature,
  });

  final String? paymentId;
  final String? subscriptionId;
  final String? signature;
}

/// Razorpay reported an error or the user closed the checkout.
final class PlanPaymentFailed extends PlanPurchaseEvent {
  const PlanPaymentFailed({this.code, this.message});

  final int? code;
  final String? message;
}

/// The user picked an external wallet; the result arrives via webhook.
final class PlanPaymentExternalWallet extends PlanPurchaseEvent {
  const PlanPaymentExternalWallet(this.walletName);

  final String? walletName;
}

/// Checks the server again, e.g. after "activation in progress".
final class PlanPurchaseStatusRechecked extends PlanPurchaseEvent {
  const PlanPurchaseStatusRechecked();
}

/// The UI has shown the outcome; go back to idle.
final class PlanPurchaseReset extends PlanPurchaseEvent {
  const PlanPurchaseReset();
}
