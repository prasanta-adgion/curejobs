import '../../../../core/result/result.dart';
import '../entities/specialization.dart';

/// Contract the domain depends on; the data layer provides the implementation.
abstract interface class SpecializationRepository {
  Future<Result<List<Specialization>>> getSpecializations({
    required String categoryId,
  });
}
