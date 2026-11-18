import '../../../../core/result/result.dart';
import '../entities/payment_record.dart';
import '../entities/plan_history_entry.dart';

abstract interface class BillingHistoryRepository {
  Future<Result<List<PaymentRecord>>> getPayments();

  Future<Result<PlanHistoryPage>> getPlanHistory({
    required int page,
    required int limit,
  });
}
