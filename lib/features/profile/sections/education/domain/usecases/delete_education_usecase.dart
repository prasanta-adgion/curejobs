import '../../../../../../core/result/result.dart';
import '../repositories/education_repository.dart';

/// Removes one education entry by id.
class DeleteEducationUseCase {
  final EducationRepository _repository;

  const DeleteEducationUseCase(this._repository);

  Future<Result<void>> call(String id) => _repository.deleteEducation(id);
}
