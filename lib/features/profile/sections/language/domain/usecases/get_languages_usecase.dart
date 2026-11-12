import '../../../../../../core/result/result.dart';
import '../entities/language.dart';
import '../repositories/language_repository.dart';

/// Loads the candidate's languages.
class GetLanguagesUseCase {
  final LanguageRepository _repository;

  const GetLanguagesUseCase(this._repository);

  Future<Result<List<Language>>> call() => _repository.getLanguages();
}
