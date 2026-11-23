import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/organization_details_model.dart';

abstract interface class OrganizationRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<OrganizationDetailsModel> getOrganization({required String slug});
}

class OrganizationRemoteDataSourceImpl implements OrganizationRemoteDataSource {
  final ApiClient _client;

  const OrganizationRemoteDataSourceImpl(this._client);

  @override
  Future<OrganizationDetailsModel> getOrganization({required String slug}) {
    return _client.get<OrganizationDetailsModel>(
      ApiEndpoints.organizationById(slug: slug),
      decoder: OrganizationDetailsModel.fromJson,
    );
  }
}
