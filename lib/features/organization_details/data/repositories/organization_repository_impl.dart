import '../../../../core/result/result.dart';
import '../../domain/entities/organization_details.dart';
import '../../domain/repositories/organization_repository.dart';
import '../datasources/organization_remote_data_source.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  final OrganizationRemoteDataSource _remote;

  const OrganizationRepositoryImpl(this._remote);

  @override
  Future<Result<OrganizationDetails>> getOrganization({required String slug}) {
    return Result.guard(() => _remote.getOrganization(slug: slug));
  }
}
