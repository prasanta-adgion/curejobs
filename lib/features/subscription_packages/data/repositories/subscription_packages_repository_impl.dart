import '../../../../core/result/result.dart';
import '../../domain/entities/current_subscription.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/entities/subscription_package.dart';
import '../../domain/repositories/subscription_packages_repository.dart';
import '../datasources/subscription_packages_remote_data_source.dart';

class SubscriptionPackagesRepositoryImpl
    implements SubscriptionPackagesRepository {
  final SubscriptionPackagesRemoteDataSource _remote;

  const SubscriptionPackagesRepositoryImpl(this._remote);

  @override
  Future<Result<List<SubscriptionPackage>>> getPackages(PackageType type) {
    return Result.guard(() => _remote.getPackages(type));
  }

  @override
  Future<Result<CurrentSubscription>> getCurrentPlan() {
    return Result.guard(_remote.getCurrentPlan);
  }

  @override
  Future<Result<Purchase>> createPurchase({
    required String billingOptionId,
    required String idempotencyKey,
  }) {
    return Result.guard(
      () => _remote.createPurchase(
        billingOptionId: billingOptionId,
        idempotencyKey: idempotencyKey,
      ),
    );
  }

  @override
  Future<Result<RazorpayCheckout>> createRazorpaySubscription(
    String purchaseId,
  ) {
    return Result.guard(() => _remote.createRazorpaySubscription(purchaseId));
  }

  @override
  Future<Result<PaymentVerification>> verifyRazorpayPayment({
    required String purchaseId,
    required String paymentId,
    required String subscriptionId,
    required String signature,
  }) {
    return Result.guard(
      () => _remote.verifyRazorpayPayment(
        purchaseId: purchaseId,
        paymentId: paymentId,
        subscriptionId: subscriptionId,
        signature: signature,
      ),
    );
  }

  @override
  Future<Result<void>> selectPlan(String packageId) {
    return Result.guard(() => _remote.selectPlan(packageId));
  }

  @override
  Future<Result<void>> cancelAutoRenew(String subscriptionId) {
    return Result.guard(() => _remote.cancelAutoRenew(subscriptionId));
  }
}
