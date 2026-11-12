import '../../../../../../core/result/result.dart';
import '../entities/education.dart';
import '../entities/education_params.dart';

/// Contract the domain depends on; the data layer provides the implementation.
abstract interface class EducationRepository {
  Future<Result<List<Education>>> getEducation();

  Future<Result<void>> addEducation(EducationParams params);

  Future<Result<void>> updateEducation(String id, EducationParams params);

  Future<Result<void>> deleteEducation(String id);
}
