import '../../../../../../core/result/result.dart';
import '../repositories/language_repository.dart';

/// Removes one language by id.
class DeleteLanguageUseCase {
  final LanguageRepository _repository;

  const DeleteLanguageUseCase(this._repository);

  Future<Result<void>> call(String id) => _repository.deleteLanguage(id);
}
