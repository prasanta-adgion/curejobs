import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../model/apply_application_response_model.dart';

abstract interface class ApplyApplicationRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  ///
  /// [status] is the API value (e.g. `UNDER_REVIEW`); null returns all.
  Future<ApplicationsPageModel> getMyApplications({
    required int page,
    required int limit,
    String? status,
  });

  /// Throws a `Failure` on error.
  Future<void> withdrawApplication(String id);
}

class ApplyApplicationRemoteDataSourceImpl
    implements ApplyApplicationRemoteDataSource {
  final ApiClient _client;

  const ApplyApplicationRemoteDataSourceImpl(this._client);

  @override
  Future<ApplicationsPageModel> getMyApplications({
    required int page,
    required int limit,
    String? status,
  }) {
    return _client.get<ApplicationsPageModel>(
      ApiEndpoints.applyApplications,
      queryParameters: {
        'page': page,
        'limit': limit,
        'status': ?status,
      },
      decoder: ApplicationsPageModel.fromJson,
    );
  }

  @override
  Future<void> withdrawApplication(String id) {
    return _client.patch<void>(ApiEndpoints.withdrawApplication(id: id));
  }
}
