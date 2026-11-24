import '../../../../core/result/result.dart';
import '../entities/purchase.dart';
import '../repositories/subscription_packages_repository.dart';

/// Step 1: creates a PENDING purchase for a billing option.
///
/// Reuse the same [idempotencyKey] when retrying the same attempt so the
/// server returns the existing purchase instead of creating another.
class CreatePurchaseUseCase {
  final SubscriptionPackagesRepository _repository;

  const CreatePurchaseUseCase(this._repository);

  Future<Result<Purchase>> call({
    required String billingOptionId,
    required String idempotencyKey,
  }) => _repository.createPurchase(
    billingOptionId: billingOptionId,
    idempotencyKey: idempotencyKey,
  );
}

/// Step 2: creates the Razorpay subscription for a purchase and returns
/// the checkout options.
class CreateRazorpaySubscriptionUseCase {
  final SubscriptionPackagesRepository _repository;

  const CreateRazorpaySubscriptionUseCase(this._repository);

  Future<Result<RazorpayCheckout>> call(String purchaseId) =>
      _repository.createRazorpaySubscription(purchaseId);
}

/// Step 3: sends Razorpay's success payload to the server, which checks the
/// signature and activates the plan.
class VerifyRazorpayPaymentUseCase {
  final SubscriptionPackagesRepository _repository;

  const VerifyRazorpayPaymentUseCase(this._repository);

  Future<Result<PaymentVerification>> call({
    required String purchaseId,
    required String paymentId,
    required String subscriptionId,
    required String signature,
  }) => _repository.verifyRazorpayPayment(
    purchaseId: purchaseId,
    paymentId: paymentId,
    subscriptionId: subscriptionId,
    signature: signature,
  );
}

/// Step 4: after a confirmed payment, selects the bought package as the
/// user's plan (`POST subscriptions/select`).
class SelectPlanUseCase {
  final SubscriptionPackagesRepository _repository;

  const SelectPlanUseCase(this._repository);

  Future<Result<void>> call(String packageId) =>
      _repository.selectPlan(packageId);
}
