import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/network/api_endpoints.dart';
import '../../domain/entities/certification_params.dart';
import '../models/certification_model.dart';
import '../models/certification_params_json.dart';

abstract interface class CertificationRemoteDataSource {
  /// All methods throw a `Failure` on error (see [ApiClient]).
  Future<List<CertificationModel>> getCertifications();

  Future<void> addCertification(CertificationParams params);

  Future<void> updateCertification(String id, CertificationParams params);

  Future<void> deleteCertification(String id);
}

class CertificationRemoteDataSourceImpl
    implements CertificationRemoteDataSource {
  final ApiClient _client;

  const CertificationRemoteDataSourceImpl(this._client);

  @override
  Future<List<CertificationModel>> getCertifications() {
    return _client.get<List<CertificationModel>>(
      ApiEndpoints.certificates,
      decoder: CertificationModel.listFromJson,
    );
  }

  @override
  Future<void> addCertification(CertificationParams params) {
    return _client.post<void>(ApiEndpoints.certificates, body: params.toJson());
  }

  @override
  Future<void> updateCertification(String id, CertificationParams params) {
    return _client.patch<void>(
      ApiEndpoints.certificateById(id: id),
      body: params.toJson(),
    );
  }

  @override
  Future<void> deleteCertification(String id) {
    return _client.delete<void>(ApiEndpoints.certificateById(id: id));
  }
}
