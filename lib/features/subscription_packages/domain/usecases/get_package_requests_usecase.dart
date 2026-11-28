import '../../../../core/result/result.dart';
import '../entities/package_request.dart';
import '../repositories/subscription_packages_repository.dart';

/// The user's package requests, newest first
/// (`GET subscriptions/me/package-requests`).
class GetPackageRequestsUseCase {
  final SubscriptionPackagesRepository _repository;

  const GetPackageRequestsUseCase(this._repository);

  Future<Result<List<PackageRequest>>> call() =>
      _repository.getPackageRequests();
}
