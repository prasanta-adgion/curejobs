part of 'payments_bloc.dart';

enum PaymentsStatus { loading, success, failure }

class PaymentsState extends Equatable {
  const PaymentsState({
    this.status = PaymentsStatus.loading,
    this.items = const [],
    this.failure,
  });

  final PaymentsStatus status;

  /// Newest first.
  final List<PaymentRecord> items;
  final Failure? failure;

  List<PaymentRecord> get successful =>
      items.where((p) => p.isSuccess).toList();

  int get failedCount =>
      items.where((p) => p.status == PaymentStatus.failed).length;

  @override
  List<Object?> get props => [status, items, failure];
}
