import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/application_detail_model.dart';

abstract interface class ApplicationDetailRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<ApplicationDetailModel> getApplication(String id);
}

class ApplicationDetailRemoteDataSourceImpl
    implements ApplicationDetailRemoteDataSource {
  final ApiClient _client;

  const ApplicationDetailRemoteDataSourceImpl(this._client);

  @override
  Future<ApplicationDetailModel> getApplication(String id) {
    return _client.get<ApplicationDetailModel>(
      ApiEndpoints.appliedApplicationById(appliedJobId: id),
      decoder: ApplicationDetailModel.fromJson,
    );
  }
}
