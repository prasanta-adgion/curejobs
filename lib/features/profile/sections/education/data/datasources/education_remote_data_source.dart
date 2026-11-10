import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/network/api_endpoints.dart';
import '../models/education_model.dart';

abstract interface class EducationRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<List<EducationModel>> getEducation();
}

class EducationRemoteDataSourceImpl implements EducationRemoteDataSource {
  final ApiClient _client;

  const EducationRemoteDataSourceImpl(this._client);

  @override
  Future<List<EducationModel>> getEducation() {
    return _client.get<List<EducationModel>>(
      ApiEndpoints.candidateEducation,
      decoder: EducationModel.listFromJson,
    );
  }
}
