part of 'plan_purchase_bloc.dart';

enum PlanPurchaseStatus {
  idle,

  /// Calling `purchases` and the Razorpay subscription endpoint.
  creating,

  /// [PlanPurchaseState.checkout] is ready; the page opens Razorpay.
  checkoutReady,

  /// Razorpay is open.
  inCheckout,

  /// Payment done on Razorpay; waiting for the server to activate the plan.
  verifying,

  /// The server shows the new plan as active.
  success,

  /// Paid, but the server hasn't activated it yet (webhook delay).
  pendingActivation,

  /// The user closed the checkout.
  cancelled,

  failure,
}

class PlanPurchaseState extends Equatable {
  const PlanPurchaseState({
    this.status = PlanPurchaseStatus.idle,
    this.checkout,
    this.planName,
    this.message,
  });

  final PlanPurchaseStatus status;
  final RazorpayCheckout? checkout;
  final String? planName;
  final String? message;

  /// True while the Buy button must stay disabled and back is blocked.
  bool get isBusy =>
      status == PlanPurchaseStatus.creating ||
      status == PlanPurchaseStatus.checkoutReady ||
      status == PlanPurchaseStatus.inCheckout ||
      status == PlanPurchaseStatus.verifying;

  PlanPurchaseState copyWith({
    PlanPurchaseStatus? status,
    RazorpayCheckout? checkout,
    String? planName,
    String? message,
  }) => PlanPurchaseState(
    status: status ?? this.status,
    checkout: checkout ?? this.checkout,
    planName: planName ?? this.planName,
    message: message,
  );

  @override
  List<Object?> get props => [status, checkout, planName, message];
}
