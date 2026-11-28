part of 'plan_purchase_bloc.dart';

enum PlanPurchaseStatus {
  idle,

  /// Free plan: calling `subscriptions/select`.
  selectingFreePlan,

  /// Free plan is now the active plan.
  freePlanSelected,

  /// Paid plan: calling `purchases` and the Razorpay subscription endpoint.
  creating,

  /// [PlanPurchaseState.checkout] is ready; the page opens Razorpay.
  checkoutReady,

  /// Razorpay is open.
  inCheckout,

  /// Paid on Razorpay; verifying the payment and selecting the plan.
  verifying,

  /// Payment verified and the paid plan is selected.
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

  /// True while the plan button must stay disabled and back is blocked.
  bool get isBusy =>
      status == PlanPurchaseStatus.selectingFreePlan ||
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
