import '../../../../core/result/result.dart';
import '../repositories/subscription_packages_repository.dart';

/// Asks admin to grant a package that can't be paid for online
/// (`POST subscriptions/me/package-requests`).
class RequestPackageUseCase {
  final SubscriptionPackagesRepository _repository;

  const RequestPackageUseCase(this._repository);

  Future<Result<void>> call({required String packageId, String? message}) =>
      _repository.requestPackage(packageId: packageId, message: message);
}
