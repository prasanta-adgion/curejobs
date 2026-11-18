import '../../../../core/result/result.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/entities/plan_history_entry.dart';
import '../../domain/repositories/billing_history_repository.dart';
import '../datasources/billing_history_remote_data_source.dart';

class BillingHistoryRepositoryImpl implements BillingHistoryRepository {
  final BillingHistoryRemoteDataSource _remote;

  const BillingHistoryRepositoryImpl(this._remote);

  @override
  Future<Result<List<PaymentRecord>>> getPayments() {
    return Result.guard(_remote.getPayments);
  }

  @override
  Future<Result<PlanHistoryPage>> getPlanHistory({
    required int page,
    required int limit,
  }) {
    return Result.guard(() => _remote.getPlanHistory(page: page, limit: limit));
  }
}
