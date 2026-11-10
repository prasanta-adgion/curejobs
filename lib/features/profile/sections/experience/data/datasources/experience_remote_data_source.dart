import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/network/api_endpoints.dart';
import '../../domain/entities/experience_params.dart';
import '../models/experience_model.dart';
import '../models/experience_params_json.dart';

abstract interface class ExperienceRemoteDataSource {
  /// All methods throw a `Failure` on error (see [ApiClient]).
  Future<List<ExperienceModel>> getExperience();

  Future<void> addExperience(ExperienceParams params);

  Future<void> updateExperience(String id, ExperienceParams params);

  Future<void> deleteExperience(String id);
}

class ExperienceRemoteDataSourceImpl implements ExperienceRemoteDataSource {
  final ApiClient _client;

  const ExperienceRemoteDataSourceImpl(this._client);

  @override
  Future<List<ExperienceModel>> getExperience() {
    return _client.get<List<ExperienceModel>>(
      ApiEndpoints.candidateExperience,
      decoder: ExperienceModel.listFromJson,
    );
  }

  @override
  Future<void> addExperience(ExperienceParams params) {
    return _client.post<void>(
      ApiEndpoints.candidateExperience,
      body: params.toJson(),
    );
  }

  @override
  Future<void> updateExperience(String id, ExperienceParams params) {
    return _client.patch<void>(
      ApiEndpoints.candidateExperienceById(id: id),
      body: params.toJson(),
    );
  }

  @override
  Future<void> deleteExperience(String id) {
    return _client.delete<void>(ApiEndpoints.candidateExperienceById(id: id));
  }
}
