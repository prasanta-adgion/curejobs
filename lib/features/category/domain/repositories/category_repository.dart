import '../../../../core/result/result.dart';
import '../entities/category.dart';

/// Contract the domain depends on; the data layer provides the implementation.
abstract interface class CategoryRepository {
  Future<Result<List<Category>>> getCategories();
}
