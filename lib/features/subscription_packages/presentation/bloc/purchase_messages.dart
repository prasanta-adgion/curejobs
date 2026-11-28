import 'dart:convert';

import '../../../../core/error/failure.dart';

/// User-facing texts for the plan purchase flow, kept out of the bloc so the
/// bloc only describes the flow.
abstract final class PurchaseMessages {
  static const generic = 'Something went wrong. Please try again.';
  static const couldNotStart = "Couldn't start the payment. Please try again.";
  static const cancelled = 'Payment cancelled. You have not been charged.';
  static const network =
      'Network problem during payment. Check your connection and try again.';
  static const activationPending =
      'Payment received. Your plan is being activated; this can take a few '
      'minutes.';

  static String notPurchasable(String plan) =>
      '$plan is not available for purchase right now.';

  static String active(String? plan) => '${plan ?? 'Your plan'} is now active.';

  static String verificationRejected(String paymentId) =>
      "We couldn't verify this payment. If you were charged, it will be "
      'refunded or activated shortly; contact support with payment ID '
      '$paymentId.';

  static String fromFailure(Failure? f) {
    if (f == null) return generic;
    if (f is ConflictFailure && f.message.isEmpty) {
      return 'You already have a payment in progress for this plan.';
    }
    return f.message.isEmpty ? generic : f.message;
  }

  /// Razorpay sends `message` as plain text or as JSON
  /// (`{"error":{"description":"..."}}`).
  static String fromRazorpay(String? raw) {
    const fallback = 'Payment failed. Please try again.';
    if (raw == null || raw.trim().isEmpty) return fallback;
    try {
      final json = jsonDecode(raw);
      if (json is Map) {
        final err = json['error'];
        final desc = err is Map ? err['description'] : json['description'];
        if (desc is String && desc.isNotEmpty) return desc;
      }
    } catch (_) {
      // Plain text.
    }
    return raw;
  }
}
