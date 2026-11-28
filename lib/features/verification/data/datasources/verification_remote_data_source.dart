import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/candidate_verification_model.dart';
import '../models/verification_document_type_model.dart';
import '../models/verification_eligibility_model.dart';
import '../models/verification_request_detail_model.dart';
import '../models/verification_request_model.dart';

abstract interface class VerificationRemoteDataSource {
  /// Throws a `Failure` on error (see [ApiClient]).
  Future<VerificationEligibilityModel> getEligibility();

  /// Document types the user can upload. Throws a `Failure` on error.
  Future<List<VerificationDocumentTypeModel>> getDocumentTypes();

  /// The user's own verification (`GET verifications/me`): status, badge,
  /// and the started request, if any. Throws a `Failure` on error.
  Future<CandidateVerificationModel> getMyVerification();

  /// Starts (or returns the open) verification request
  /// (`POST verifications`). Throws a `Failure` on error.
  Future<VerificationRequestModel> createRequest();

  /// Attaches an uploaded file to verification request [verificationId].
  Future<void> addDocument({
    required String verificationId,
    required String documentTypeId,
    required String fileId,
  });

  /// The request with its documents and review outcome
  /// (`GET verifications/{id}`). Throws a `Failure` on error.
  Future<VerificationRequestDetailModel> getRequestDetail({
    required String verificationId,
  });

  /// Sends the request for admin review (`POST verifications/{id}/submit`).
  /// Throws a `Failure` on error.
  Future<VerificationRequestDetailModel> submitForReview({
    required String verificationId,
  });

  /// Deletes one attached document
  /// (`DELETE verifications/{verificationId}/documents/{documentId}`).
  /// Throws a `Failure` on error.
  Future<void> deleteDocument({
    required String verificationId,
    required String documentId,
  });
}

class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
  final ApiClient _client;

  const VerificationRemoteDataSourceImpl(this._client);

  @override
  Future<VerificationEligibilityModel> getEligibility() {
    return _client.get<VerificationEligibilityModel>(
      ApiEndpoints.verificationEligibility,
      decoder: VerificationEligibilityModel.dataFromJson,
    );
  }

  @override
  Future<List<VerificationDocumentTypeModel>> getDocumentTypes() {
    return _client.get<List<VerificationDocumentTypeModel>>(
      ApiEndpoints.documentTypes,
      decoder: VerificationDocumentTypeModel.listFromJson,
    );
  }

  @override
  Future<CandidateVerificationModel> getMyVerification() {
    return _client.get<CandidateVerificationModel>(
      ApiEndpoints.candidateVerification,
      decoder: CandidateVerificationModel.dataFromJson,
    );
  }

  @override
  Future<VerificationRequestModel> createRequest() {
    return _client.post<VerificationRequestModel>(
      ApiEndpoints.verification,
      decoder: VerificationRequestModel.dataFromJson,
    );
  }

  @override
  Future<void> addDocument({
    required String verificationId,
    required String documentTypeId,
    required String fileId,
  }) async {
    await _client.post<dynamic>(
      ApiEndpoints.documentUpload(id: verificationId),
      body: {'documentTypeId': documentTypeId, 'fileId': fileId},
    );
  }

  @override
  Future<VerificationRequestDetailModel> getRequestDetail({
    required String verificationId,
  }) {
    return _client.get<VerificationRequestDetailModel>(
      ApiEndpoints.documentVerificationStatus(id: verificationId),
      decoder: VerificationRequestDetailModel.dataFromJson,
    );
  }

  @override
  Future<VerificationRequestDetailModel> submitForReview({
    required String verificationId,
  }) {
    return _client.post<VerificationRequestDetailModel>(
      ApiEndpoints.submitDocument(id: verificationId),
      decoder: VerificationRequestDetailModel.dataFromJson,
    );
  }

  @override
  Future<void> deleteDocument({
    required String verificationId,
    required String documentId,
  }) async {
    await _client.delete<dynamic>(
      ApiEndpoints.deleteDocument(
        id: verificationId,
        documentDeleteId: documentId,
      ),
    );
  }
}
