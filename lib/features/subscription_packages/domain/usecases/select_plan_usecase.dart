import '../../../../core/result/result.dart';
import '../repositories/subscription_packages_repository.dart';

/// Makes a package the user's active plan (`POST subscriptions/select`).
///
/// - Free plan: called directly when the user taps "Continue with …".
/// - Paid plan: step 4 of 4, called only after the payment is verified.
class SelectPlanUseCase {
  final SubscriptionPackagesRepository _repository;

  const SelectPlanUseCase(this._repository);

  Future<Result<void>> call({required String packageId}) =>
      _repository.selectPlan(packageId);
}
