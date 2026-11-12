import '../../../../../../core/result/result.dart';
import '../entities/education_params.dart';
import '../repositories/education_repository.dart';

/// Adds new education, or updates one when [id] is given.
class SaveEducationUseCase {
  final EducationRepository _repository;

  const SaveEducationUseCase(this._repository);

  Future<Result<void>> call(EducationParams params, {String? id}) {
    return id == null
        ? _repository.addEducation(params)
        : _repository.updateEducation(id, params);
  }
}
