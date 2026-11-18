import '../../../../core/result/result.dart';
import '../entities/current_subscription.dart';
import '../repositories/subscription_packages_repository.dart';

/// Loads the signed-in user's active plan, limits and features.
class GetCurrentPlanUseCase {
  final SubscriptionPackagesRepository _repository;

  const GetCurrentPlanUseCase(this._repository);

  Future<Result<CurrentSubscription>> call() => _repository.getCurrentPlan();
}
