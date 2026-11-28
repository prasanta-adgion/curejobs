import '../../../../core/result/result.dart';
import '../../domain/entities/candidate_verification.dart';
import '../../domain/entities/verification_document_type.dart';
import '../../domain/entities/verification_eligibility.dart';
import '../../domain/entities/verification_request_detail.dart';
import '../../domain/repositories/verification_repository.dart';
import '../datasources/verification_remote_data_source.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  final VerificationRemoteDataSource _remote;

  const VerificationRepositoryImpl(this._remote);

  @override
  Future<Result<VerificationEligibility>> getEligibility() {
    return Result.guard(_remote.getEligibility);
  }

  @override
  Future<Result<List<VerificationDocumentType>>> getDocumentTypes() {
    return Result.guard(_remote.getDocumentTypes);
  }

  @override
  Future<Result<CandidateVerification>> getMyVerification() {
    return Result.guard(_remote.getMyVerification);
  }

  @override
  Future<Result<VerificationRequest>> createRequest() {
    return Result.guard(_remote.createRequest);
  }

  @override
  Future<Result<void>> addDocument({
    required String verificationId,
    required String documentTypeId,
    required String fileId,
  }) {
    return Result.guard(
      () => _remote.addDocument(
        verificationId: verificationId,
        documentTypeId: documentTypeId,
        fileId: fileId,
      ),
    );
  }

  @override
  Future<Result<VerificationRequestDetail>> getRequestDetail({
    required String verificationId,
  }) {
    return Result.guard(
      () => _remote.getRequestDetail(verificationId: verificationId),
    );
  }

  @override
  Future<Result<VerificationRequestDetail>> submitForReview({
    required String verificationId,
  }) {
    return Result.guard(
      () => _remote.submitForReview(verificationId: verificationId),
    );
  }

  @override
  Future<Result<void>> deleteDocument({
    required String verificationId,
    required String documentId,
  }) {
    return Result.guard(
      () => _remote.deleteDocument(
        verificationId: verificationId,
        documentId: documentId,
      ),
    );
  }
}
