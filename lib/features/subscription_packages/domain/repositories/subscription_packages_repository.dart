import '../../../../core/result/result.dart';
import '../entities/current_subscription.dart';
import '../entities/purchase.dart';
import '../entities/subscription_package.dart';

abstract interface class SubscriptionPackagesRepository {
  Future<Result<List<SubscriptionPackage>>> getPackages(PackageType type);

  Future<Result<CurrentSubscription>> getCurrentPlan();

  Future<Result<Purchase>> createPurchase({
    required String billingOptionId,
    required String idempotencyKey,
  });

  Future<Result<RazorpayCheckout>> createRazorpaySubscription(
    String purchaseId,
  );

  Future<Result<PaymentVerification>> verifyRazorpayPayment({
    required String purchaseId,
    required String paymentId,
    required String subscriptionId,
    required String signature,
  });

  Future<Result<void>> selectPlan(String packageId);
}
