import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/application_eligibility_model.dart';

abstract interface class ApplyJobRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<ApplicationEligibilityModel> getEligibility(String jobId);
}

class ApplyJobRemoteDataSourceImpl implements ApplyJobRemoteDataSource {
  final ApiClient _client;

  const ApplyJobRemoteDataSourceImpl(this._client);

  @override
  Future<ApplicationEligibilityModel> getEligibility(String jobId) {
    return _client.get<ApplicationEligibilityModel>(
      ApiEndpoints.jobApplicationEligibility(id: jobId),
      decoder: ApplicationEligibilityModel.fromJson,
    );
  }
}
