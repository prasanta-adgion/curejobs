import '../../../../core/result/result.dart';
import '../entities/payment_record.dart';
import '../repositories/billing_history_repository.dart';

/// Loads the signed-in user's payment attempts, newest first.
class GetPaymentsUseCase {
  final BillingHistoryRepository _repository;

  const GetPaymentsUseCase(this._repository);

  Future<Result<List<PaymentRecord>>> call() => _repository.getPayments();
}
