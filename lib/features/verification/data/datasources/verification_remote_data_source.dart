import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/verification_document_type.dart';
import '../../domain/entities/verification_eligibility.dart';
import '../models/verification_document_type_model.dart';
import '../models/verification_eligibility_model.dart';

abstract interface class VerificationRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<VerificationEligibility> getEligibility();

  /// Document types the user can upload. Throws a `Failure` on error.
  Future<List<VerificationDocumentType>> getDocumentTypes();

  /// Attaches an uploaded file to verification request [verificationId].
  Future<void> addDocument({
    required String verificationId,
    required String documentTypeId,
    required String fileId,
  });
}

class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
  final ApiClient _client;

  const VerificationRemoteDataSourceImpl(this._client);

  @override
  Future<VerificationEligibility> getEligibility() {
    return _client.get<VerificationEligibility>(
      ApiEndpoints.verificationEligibility,
      decoder: VerificationEligibilityModel.fromJson,
    );
  }

  @override
  Future<List<VerificationDocumentType>> getDocumentTypes() {
    return _client.get<List<VerificationDocumentType>>(
      ApiEndpoints.documentTypes,
      decoder: VerificationDocumentTypeModel.listFromJson,
    );
  }

  @override
  Future<void> addDocument({
    required String verificationId,
    required String documentTypeId,
    required String fileId,
  }) async {
    await _client.post<dynamic>(
      ApiEndpoints.documentTypeById(id: verificationId),
      body: {'documentTypeId': documentTypeId, 'fileId': fileId},
    );
  }
}
