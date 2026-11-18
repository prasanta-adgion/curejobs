import '../../../../core/result/result.dart';
import '../../domain/entities/current_subscription.dart';
import '../../domain/entities/subscription_package.dart';
import '../../domain/repositories/subscription_packages_repository.dart';
import '../datasources/subscription_packages_remote_data_source.dart';

class SubscriptionPackagesRepositoryImpl
    implements SubscriptionPackagesRepository {
  final SubscriptionPackagesRemoteDataSource _remote;

  const SubscriptionPackagesRepositoryImpl(this._remote);

  @override
  Future<Result<List<SubscriptionPackage>>> getPackages(PackageType type) {
    return Result.guard(() => _remote.getPackages(type));
  }

  @override
  Future<Result<CurrentSubscription>> getCurrentPlan() {
    return Result.guard(_remote.getCurrentPlan);
  }
}
