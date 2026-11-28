import '../../../../core/result/result.dart';
import '../entities/current_subscription.dart';
import '../repositories/subscription_packages_repository.dart';

/// Turns off auto-pay for the user's paid plan
/// (`POST subscriptions/{id}/cancel-autorenew`).
///
/// The plan stays active until it expires; it just won't renew.
class CancelAutoRenewUseCase {
  final SubscriptionPackagesRepository _repository;

  const CancelAutoRenewUseCase(this._repository);

  Future<Result<void>> call(CurrentSubscription subscription) =>
      _repository.cancelAutoRenew(subscription.id);
}
