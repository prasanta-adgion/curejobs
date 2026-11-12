import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/network/api_endpoints.dart';
import '../models/skill_model.dart';

abstract interface class SkillRemoteDataSource {
  /// All methods throw a `Failure` on error (see [ApiClient]).
  Future<List<SkillModel>> getSkills();

  /// Sends `{name}`.
  Future<void> addSkill(String name);

  Future<void> deleteSkill(String id);
}

class SkillRemoteDataSourceImpl implements SkillRemoteDataSource {
  final ApiClient _client;

  const SkillRemoteDataSourceImpl(this._client);

  @override
  Future<List<SkillModel>> getSkills() {
    return _client.get<List<SkillModel>>(
      ApiEndpoints.skills,
      decoder: SkillModel.listFromJson,
    );
  }

  @override
  Future<void> addSkill(String name) {
    return _client.post<void>(ApiEndpoints.skills, body: {'name': name});
  }

  @override
  Future<void> deleteSkill(String id) {
    return _client.delete<void>(ApiEndpoints.skillById(id: id));
  }
}
