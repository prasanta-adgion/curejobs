import '../../../../core/result/result.dart';
import '../entities/subscription_package.dart';

abstract interface class SubscriptionPackagesRepository {
  Future<Result<List<SubscriptionPackage>>> getPackages(PackageType type);
}
