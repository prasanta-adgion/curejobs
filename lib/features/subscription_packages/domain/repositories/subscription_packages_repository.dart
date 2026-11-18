import '../../../../core/result/result.dart';
import '../entities/current_subscription.dart';
import '../entities/subscription_package.dart';

abstract interface class SubscriptionPackagesRepository {
  Future<Result<List<SubscriptionPackage>>> getPackages(PackageType type);

  Future<Result<CurrentSubscription>> getCurrentPlan();
}
