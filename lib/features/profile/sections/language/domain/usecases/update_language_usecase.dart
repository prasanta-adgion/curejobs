import '../../../../../../core/result/result.dart';
import '../entities/language.dart';
import '../repositories/language_repository.dart';

/// Changes the proficiency of one language.
class UpdateLanguageUseCase {
  final LanguageRepository _repository;

  const UpdateLanguageUseCase(this._repository);

  Future<Result<void>> call({
    required String id,
    required LanguageProficiency proficiency,
  }) => _repository.updateLanguage(id: id, proficiency: proficiency);
}
