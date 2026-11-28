import '../../../../core/result/result.dart';
import '../entities/purchase.dart';
import '../repositories/subscription_packages_repository.dart';

/// Paid flow — step 2 of 4: creates the Razorpay subscription for a purchase
/// and returns the options needed to open the Razorpay checkout.
class CreateRazorpaySubscriptionUseCase {
  final SubscriptionPackagesRepository _repository;

  const CreateRazorpaySubscriptionUseCase(this._repository);

  Future<Result<RazorpayCheckout>> call(String purchaseId) =>
      _repository.createRazorpaySubscription(purchaseId);
}
