import '../../../../core/result/result.dart';
import '../entities/organization_details.dart';
import '../repositories/organization_repository.dart';

/// Loads an employer's public profile by its slug (or id).
class GetOrganizationUseCase {
  final OrganizationRepository _repository;

  const GetOrganizationUseCase(this._repository);

  Future<Result<OrganizationDetails>> call(String slug) =>
      _repository.getOrganization(slug: slug);
}
