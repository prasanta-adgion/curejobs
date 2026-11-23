import '../../../../core/result/result.dart';
import '../entities/organization_details.dart';

abstract interface class OrganizationRepository {
  Future<Result<OrganizationDetails>> getOrganization({required String slug});
}
