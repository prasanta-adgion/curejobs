import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/category_model.dart';

abstract interface class CategoryRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<List<CategoryModel>> getCategories();
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient _client;

  const CategoryRemoteDataSourceImpl(this._client);

  @override
  Future<List<CategoryModel>> getCategories() {
    return _client.get<List<CategoryModel>>(
      ApiEndpoints.categories,
      decoder: CategoryModel.listFromJson,
    );
  }
}
