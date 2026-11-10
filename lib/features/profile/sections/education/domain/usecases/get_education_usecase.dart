import '../../../../../../core/result/result.dart';
import '../entities/education.dart';
import '../repositories/education_repository.dart';

/// Loads the signed-in candidate's education history.
class GetEducationUseCase {
  final EducationRepository _repository;

  const GetEducationUseCase(this._repository);

  Future<Result<List<Education>>> call() => _repository.getEducation();
}
