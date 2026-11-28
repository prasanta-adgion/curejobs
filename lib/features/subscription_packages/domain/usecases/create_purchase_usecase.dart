import '../../../../core/result/result.dart';
import '../entities/purchase.dart';
import '../repositories/subscription_packages_repository.dart';

/// Paid flow — step 1 of 4: creates a PENDING purchase for a billing option
/// (`POST purchases`).
///
/// Reuse the same [idempotencyKey] when retrying the same attempt so the
/// server returns the existing purchase instead of creating another.
class CreatePurchaseUseCase {
  final SubscriptionPackagesRepository _repository;

  const CreatePurchaseUseCase(this._repository);

  Future<Result<Purchase>> call({
    required String billingOptionId,
    required String idempotencyKey,
  }) => _repository.createPurchase(
    billingOptionId: billingOptionId,
    idempotencyKey: idempotencyKey,
  );
}
