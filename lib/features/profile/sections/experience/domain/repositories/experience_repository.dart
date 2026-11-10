import '../../../../../../core/result/result.dart';
import '../entities/experience.dart';
import '../entities/experience_params.dart';

/// Contract the domain depends on; the data layer provides the implementation.
abstract interface class ExperienceRepository {
  Future<Result<List<Experience>>> getExperience();

  Future<Result<void>> addExperience(ExperienceParams params);

  Future<Result<void>> updateExperience(String id, ExperienceParams params);

  Future<Result<void>> deleteExperience(String id);
}
