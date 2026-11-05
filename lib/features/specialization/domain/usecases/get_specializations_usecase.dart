import '../../../../core/result/result.dart';
import '../entities/specialization.dart';
import '../repositories/specialization_repository.dart';

/// Loads the specializations of one category.
class GetSpecializationsUseCase {
  final SpecializationRepository _repository;

  const GetSpecializationsUseCase(this._repository);

  Future<Result<List<Specialization>>> call({required String categoryId}) {
    return _repository.getSpecializations(categoryId: categoryId);
  }
}
