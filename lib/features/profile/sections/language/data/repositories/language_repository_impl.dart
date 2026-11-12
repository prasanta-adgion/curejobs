import '../../../../../../core/result/result.dart';
import '../../domain/entities/language.dart';
import '../../domain/repositories/language_repository.dart';
import '../datasources/language_remote_data_source.dart';

class LanguageRepositoryImpl implements LanguageRepository {
  final LanguageRemoteDataSource _remote;

  const LanguageRepositoryImpl(this._remote);

  @override
  Future<Result<List<Language>>> getLanguages() =>
      Result.guard(_remote.getLanguages);

  @override
  Future<Result<void>> addLanguage({
    required String name,
    required LanguageProficiency proficiency,
  }) {
    return Result.guard(
      () => _remote.addLanguage(name: name, proficiency: proficiency),
    );
  }

  @override
  Future<Result<void>> updateLanguage({
    required String id,
    required LanguageProficiency proficiency,
  }) {
    return Result.guard(
      () => _remote.updateLanguage(id: id, proficiency: proficiency),
    );
  }

  @override
  Future<Result<void>> deleteLanguage(String id) {
    return Result.guard(() => _remote.deleteLanguage(id));
  }
}
