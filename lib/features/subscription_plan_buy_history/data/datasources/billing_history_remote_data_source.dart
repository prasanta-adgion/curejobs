import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/entities/plan_history_entry.dart';
import '../models/billing_models.dart';

abstract interface class BillingHistoryRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<List<PaymentRecord>> getPayments();

  /// One page of plan history. Throws a `Failure` on error.
  Future<PlanHistoryPage> getPlanHistory({
    required int page,
    required int limit,
  });
}

class BillingHistoryRemoteDataSourceImpl
    implements BillingHistoryRemoteDataSource {
  final ApiClient _client;

  const BillingHistoryRemoteDataSourceImpl(this._client);

  @override
  Future<List<PaymentRecord>> getPayments() {
    return _client.get<List<PaymentRecord>>(
      ApiEndpoints.subscribeToPlan,
      decoder: PaymentRecordModel.listFromJson,
    );
  }

  @override
  Future<PlanHistoryPage> getPlanHistory({
    required int page,
    required int limit,
  }) {
    return _client.get<PlanHistoryPage>(
      ApiEndpoints.planHistory,
      queryParameters: {'page': page, 'limit': limit},
      decoder: PlanHistoryModel.pageFromJson,
    );
  }
}
