import '../../../../core/result/result.dart';
import '../entities/subscription_package.dart';
import '../repositories/subscription_packages_repository.dart';

/// Loads the subscription plans available for [PackageType].
class GetSubscriptionPackagesUseCase {
  final SubscriptionPackagesRepository _repository;

  const GetSubscriptionPackagesUseCase(this._repository);

  Future<Result<List<SubscriptionPackage>>> call(PackageType type) =>
      _repository.getPackages(type);
}
