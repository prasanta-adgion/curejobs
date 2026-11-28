import '../../../../core/result/result.dart';
import '../entities/purchase.dart';
import '../repositories/subscription_packages_repository.dart';

/// Paid flow — step 3 of 4: after Razorpay reports success, sends its payload
/// to the server, which checks the signature and confirms the payment.
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
