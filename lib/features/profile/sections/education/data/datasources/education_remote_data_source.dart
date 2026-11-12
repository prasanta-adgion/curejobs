import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/network/api_endpoints.dart';
import '../../domain/entities/education_params.dart';
import '../models/education_model.dart';
import '../models/education_params_json.dart';

abstract interface class EducationRemoteDataSource {
  /// All methods throw a `Failure` on error (see [ApiClient]).
  Future<List<EducationModel>> getEducation();

  Future<void> addEducation(EducationParams params);

  Future<void> updateEducation(String id, EducationParams params);

  Future<void> deleteEducation(String id);
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

  @override
  Future<void> addEducation(EducationParams params) {
    return _client.post<void>(
      ApiEndpoints.candidateEducation,
      body: params.toJson(),
    );
  }

  @override
  Future<void> updateEducation(String id, EducationParams params) {
    return _client.patch<void>(
      ApiEndpoints.candidateEducationById(id: id),
      body: params.toJson(),
    );
  }

  @override
  Future<void> deleteEducation(String id) {
    return _client.delete<void>(ApiEndpoints.candidateEducationById(id: id));
  }
}
