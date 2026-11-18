import 'package:equatable/equatable.dart';

enum PaymentStatus {
  success('SUCCESS'),
  failed('FAILED'),
  pending('PENDING'),
  unknown('');

  const PaymentStatus(this.apiValue);

  final String apiValue;

  static PaymentStatus fromApi(String value) => values.firstWhere(
    (s) => s.apiValue == value,
    orElse: () => PaymentStatus.unknown,
  );
}

/// One payment attempt from `GET api/v1/payments/me`.
class PaymentRecord extends Equatable {
  const PaymentRecord({
    required this.id,
    required this.status,
    required this.amountMinor,
    required this.currency,
    this.providerPaymentId,
    this.paidAt,
    required this.createdAt,
    required this.purchaseStatus,
    required this.packageId,
    required this.packageName,
    required this.durationDays,
  });

  final String id;
  final PaymentStatus status;
  final int amountMinor;
  final String currency;

  /// Razorpay id, e.g. `pay_U1ch5QkkyfT6Ph`. Null when the payment failed.
  final String? providerPaymentId;
  final DateTime? paidAt;
  final DateTime createdAt;

  /// e.g. `PAID`, `CANCELLED`.
  final String purchaseStatus;
  final String packageId;
  final String packageName;
  final int durationDays;

  bool get isSuccess => status == PaymentStatus.success;

  /// When it was paid, or when it was attempted if it never went through.
  DateTime get date => paidAt ?? createdAt;

  @override
  List<Object?> get props => [id, status, amountMinor, paidAt];
}
