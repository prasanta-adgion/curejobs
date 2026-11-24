import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../domain/entities/purchase.dart';

/// Thin wrapper around the Razorpay SDK so the bloc stays plugin-free.
/// Create one per screen and call [dispose] when the screen goes away,
/// otherwise listeners leak and callbacks fire twice.
class RazorpayService {
  RazorpayService({
    required void Function(PaymentSuccessResponse) onSuccess,
    required void Function(PaymentFailureResponse) onError,
    required void Function(ExternalWalletResponse) onExternalWallet,
  }) {
    _razorpay
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, onError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  final Razorpay _razorpay = Razorpay();

  /// Opens checkout for a subscription. The amount comes from the
  /// subscription on Razorpay's side, so it isn't passed here.
  void open(RazorpayCheckout checkout, {String? themeColorHex}) {
    _razorpay.open({
      'key': checkout.keyId,
      'subscription_id': checkout.subscriptionId,
      'name': checkout.name,
      'description': checkout.description,
      'notes': {'purchaseId': checkout.purchaseId},
      'retry': {'enabled': true, 'max_count': 3},
      'theme': {'color': ?themeColorHex},
    });
  }

  void dispose() => _razorpay.clear();
}
