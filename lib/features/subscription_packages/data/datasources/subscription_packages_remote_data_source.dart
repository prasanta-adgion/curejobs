import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/current_subscription.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/entities/subscription_package.dart';
import '../models/current_subscription_model.dart';
import '../models/purchase_model.dart';
import '../models/subscription_package_model.dart';

abstract interface class SubscriptionPackagesRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<List<SubscriptionPackage>> getPackages(PackageType type);

  /// The signed-in user's active plan. Throws a `Failure` on error.
  Future<CurrentSubscription> getCurrentPlan();

  /// Creates a PENDING purchase for a billing option.
  Future<Purchase> createPurchase({
    required String billingOptionId,
    required String idempotencyKey,
  });

  /// Creates the Razorpay subscription for [purchaseId].
  Future<RazorpayCheckout> createRazorpaySubscription(String purchaseId);

  /// Sends Razorpay's success payload for server-side signature checking.
  Future<PaymentVerification> verifyRazorpayPayment({
    required String purchaseId,
    required String paymentId,
    required String subscriptionId,
    required String signature,
  });

  /// Makes [packageId] the active plan after it has been paid for.
  Future<void> selectPlan(String packageId);
}

class SubscriptionPackagesRemoteDataSourceImpl
    implements SubscriptionPackagesRemoteDataSource {
  final ApiClient _client;

  const SubscriptionPackagesRemoteDataSourceImpl(this._client);

  @override
  Future<List<SubscriptionPackage>> getPackages(PackageType type) {
    return _client.get<List<SubscriptionPackage>>(
      ApiEndpoints.packages,
      queryParameters: {'type': type.apiValue},
      decoder: SubscriptionPackageModel.listFromJson,
    );
  }

  @override
  Future<CurrentSubscription> getCurrentPlan() {
    return _client.get<CurrentSubscription>(
      ApiEndpoints.currentPlan,
      decoder: CurrentSubscriptionModel.fromJson,
    );
  }

  @override
  Future<Purchase> createPurchase({
    required String billingOptionId,
    required String idempotencyKey,
  }) {
    print("purchases api call");
    return _client.post<Purchase>(
      ApiEndpoints.purchases,
      body: {'billingOptionId': billingOptionId},
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      decoder: PurchaseModel.fromJson,
    );
  }

  @override
  Future<RazorpayCheckout> createRazorpaySubscription(String purchaseId) {
    print("create razorpay subscription");

    return _client.post<RazorpayCheckout>(
      ApiEndpoints.razorpaySubscription(purchaseId: purchaseId),
      decoder: RazorpayCheckoutModel.fromJson,
    );
  }

  @override
  Future<PaymentVerification> verifyRazorpayPayment({
    required String purchaseId,
    required String paymentId,
    required String subscriptionId,
    required String signature,
  }) {
    print("-------------------------------------------------");
    print("purchaseId: $purchaseId");
    print("paymentId: $paymentId");
    print("subscriptionId: $subscriptionId");
    print("signature: $signature");
    print("-------------------------------------------------");
    return _client.post<PaymentVerification>(
      ApiEndpoints.verifyRazorpayPayment,
      body: {
        'purchaseId': purchaseId,
        'razorpayPaymentId': paymentId,
        'razorpaySubscriptionId': subscriptionId,
        'razorpaySignature': signature,
      },
      decoder: PaymentVerificationModel.fromJson,
    );
  }

  @override
  Future<void> selectPlan(String packageId) {
    print("select plan api call");
    return _client.post<void>(
      ApiEndpoints.selectPlan,
      body: {'packageId': packageId},
      decoder: (_) {},
    );
  }
}
