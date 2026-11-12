import '../../../../../../core/result/result.dart';
import '../entities/language.dart';

abstract interface class LanguageRepository {
  Future<Result<List<Language>>> getLanguages();

  Future<Result<void>> addLanguage({
    required String name,
    required LanguageProficiency proficiency,
  });

  Future<Result<void>> updateLanguage({
    required String id,
    required LanguageProficiency proficiency,
  });

  Future<Result<void>> deleteLanguage(String id);
}
