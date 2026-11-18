import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/current_subscription.dart';
import '../../domain/entities/subscription_package.dart';
import '../models/current_subscription_model.dart';
import '../models/subscription_package_model.dart';

abstract interface class SubscriptionPackagesRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<List<SubscriptionPackage>> getPackages(PackageType type);

  /// The signed-in user's active plan. Throws a `Failure` on error.
  Future<CurrentSubscription> getCurrentPlan();
}

class SubscriptionPackagesRemoteDataSourceImpl
    implements SubscriptionPackagesRemoteDataSource {
  final ApiClient _client;

  const SubscriptionPackagesRemoteDataSourceImpl(this._client);

  @override
  Future<List<SubscriptionPackage>> getPackages(PackageType type) {
    return _client.get<List<SubscriptionPackage>>(
      ApiEndpoints.packages,
      queryParameters: {'type': type.apiValue},
      decoder: SubscriptionPackageModel.listFromJson,
    );
  }

  @override
  Future<CurrentSubscription> getCurrentPlan() {
    return _client.get<CurrentSubscription>(
      ApiEndpoints.currentPlan,
      decoder: CurrentSubscriptionModel.fromJson,
    );
  }
}
