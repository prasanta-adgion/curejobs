import '../../../../../../core/result/result.dart';
import '../entities/education.dart';

/// Contract the domain depends on; the data layer provides the implementation.
abstract interface class EducationRepository {
  Future<Result<List<Education>>> getEducation();
}
