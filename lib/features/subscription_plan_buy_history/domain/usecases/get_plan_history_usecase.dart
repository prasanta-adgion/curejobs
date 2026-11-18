import '../../../../core/result/result.dart';
import '../entities/plan_history_entry.dart';
import '../repositories/billing_history_repository.dart';

/// Loads one page of the user's plan history.
class GetPlanHistoryUseCase {
  final BillingHistoryRepository _repository;

  const GetPlanHistoryUseCase(this._repository);

  Future<Result<PlanHistoryPage>> call({int page = 1, int limit = 10}) =>
      _repository.getPlanHistory(page: page, limit: limit);
}
