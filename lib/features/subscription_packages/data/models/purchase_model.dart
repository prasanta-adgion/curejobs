import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/purchase.dart';

abstract final class PurchaseModel {
  static Purchase fromJson(Object? json) {
    final d = _data(json);
    return Purchase(
      id: JsonParser.string(d['id']),
      packageId: JsonParser.string(d['packageId']),
      status: JsonParser.string(d['status']),
      amountMinor: JsonParser.integer(d['amountMinor']),
      currency: JsonParser.string(d['currency'], fallback: 'INR'),
      providerSubscriptionId: JsonParser.nullableString(
        d['providerSubscriptionId'],
      ),
    );
  }
}

abstract final class RazorpayCheckoutModel {
  static RazorpayCheckout fromJson(Object? json) {
    final d = _data(json);
    return RazorpayCheckout(
      purchaseId: JsonParser.string(d['purchaseId']),
      keyId: JsonParser.string(d['keyId']),
      subscriptionId: JsonParser.string(d['subscriptionId']),
      name: JsonParser.string(d['name']),
      description: JsonParser.string(d['description']),
      amountMinor: JsonParser.integer(d['amountMinor']),
      currency: JsonParser.string(d['currency'], fallback: 'INR'),
    );
  }
}

Map<String, dynamic> _data(Object? json) {
  final root = JsonParser.map(json);
  return root.containsKey('data') ? JsonParser.map(root['data']) : root;
}

abstract final class PaymentVerificationModel {
  static PaymentVerification fromJson(Object? json) {
    final d = _data(json);
    return PaymentVerification(
      purchaseId: JsonParser.string(d['purchaseId']),
      subscriptionId: JsonParser.nullableString(d['subscriptionId']),
      status: JsonParser.string(d['status']),
    );
  }
}
