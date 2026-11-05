import '../../../../core/result/result.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Loads the job categories a candidate can choose from.
class GetCategoriesUseCase {
  final CategoryRepository _repository;

  const GetCategoriesUseCase(this._repository);

  Future<Result<List<Category>>> call() => _repository.getCategories();
}
