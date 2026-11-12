import '../../../../../../core/result/result.dart';
import '../entities/language.dart';
import '../repositories/language_repository.dart';

/// Adds one language with its proficiency.
class AddLanguageUseCase {
  final LanguageRepository _repository;

  const AddLanguageUseCase(this._repository);

  Future<Result<void>> call({
    required String name,
    required LanguageProficiency proficiency,
  }) => _repository.addLanguage(name: name.trim(), proficiency: proficiency);
}
