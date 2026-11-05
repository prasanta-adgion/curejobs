import '../../../../core/result/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_data_source.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remote;

  const CategoryRepositoryImpl(this._remote);

  @override
  Future<Result<List<Category>>> getCategories() {
    return Result.guard(_remote.getCategories);
  }
}
