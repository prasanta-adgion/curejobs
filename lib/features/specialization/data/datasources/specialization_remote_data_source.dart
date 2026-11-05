import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/specialization_model.dart';

abstract interface class SpecializationRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<List<SpecializationModel>> getSpecializations({
    required String categoryId,
  });
}

class SpecializationRemoteDataSourceImpl
    implements SpecializationRemoteDataSource {
  final ApiClient _client;

  const SpecializationRemoteDataSourceImpl(this._client);

  @override
  Future<List<SpecializationModel>> getSpecializations({
    required String categoryId,
  }) {
    return _client.get<List<SpecializationModel>>(
      ApiEndpoints.specializationsByCategory(categoryId: categoryId),
      decoder: SpecializationModel.listFromJson,
    );
  }
}
