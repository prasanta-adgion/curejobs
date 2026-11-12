import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/network/api_endpoints.dart';
import '../../domain/entities/language.dart';
import '../models/language_model.dart';

abstract interface class LanguageRemoteDataSource {
  /// All methods throw a `Failure` on error (see [ApiClient]).
  Future<List<LanguageModel>> getLanguages();

  /// Sends `{language, proficiency}`.
  Future<void> addLanguage({
    required String name,
    required LanguageProficiency proficiency,
  });

  /// Sends `{proficiency}`.
  Future<void> updateLanguage({
    required String id,
    required LanguageProficiency proficiency,
  });

  Future<void> deleteLanguage(String id);
}

class LanguageRemoteDataSourceImpl implements LanguageRemoteDataSource {
  final ApiClient _client;

  const LanguageRemoteDataSourceImpl(this._client);

  @override
  Future<List<LanguageModel>> getLanguages() {
    return _client.get<List<LanguageModel>>(
      ApiEndpoints.languages,
      decoder: LanguageModel.listFromJson,
    );
  }

  @override
  Future<void> addLanguage({
    required String name,
    required LanguageProficiency proficiency,
  }) {
    return _client.post<void>(
      ApiEndpoints.languages,
      body: {'language': name, 'proficiency': proficiency.apiValue},
    );
  }

  @override
  Future<void> updateLanguage({
    required String id,
    required LanguageProficiency proficiency,
  }) {
    return _client.patch<void>(
      ApiEndpoints.languageById(id: id),
      body: {'proficiency': proficiency.apiValue},
    );
  }

  @override
  Future<void> deleteLanguage(String id) {
    return _client.delete<void>(ApiEndpoints.languageById(id: id));
  }
}
