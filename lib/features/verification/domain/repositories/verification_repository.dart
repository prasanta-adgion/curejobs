import '../../../../core/result/result.dart';
import '../entities/candidate_verification.dart';
import '../entities/verification_document_type.dart';
import '../entities/verification_eligibility.dart';
import '../entities/verification_request_detail.dart';

abstract interface class VerificationRepository {
  Future<Result<VerificationEligibility>> getEligibility();

  Future<Result<List<VerificationDocumentType>>> getDocumentTypes();

  /// The user's own verification, incl. whether a request was started.
  Future<Result<CandidateVerification>> getMyVerification();

  /// Starts the verification request documents get attached to.
  Future<Result<VerificationRequest>> createRequest();

  /// Attaches one uploaded file to the request as [documentTypeId].
  Future<Result<void>> addDocument({
    required String verificationId,
    required String documentTypeId,
    required String fileId,
  });

  /// The request with its documents, status and rejection reason.
  Future<Result<VerificationRequestDetail>> getRequestDetail({
    required String verificationId,
  });

  /// Sends the request, with its attached documents, for admin review.
  Future<Result<VerificationRequestDetail>> submitForReview({
    required String verificationId,
  });

  /// Deletes one attached document, e.g. a rejected one before uploading
  /// a replacement.
  Future<Result<void>> deleteDocument({
    required String verificationId,
    required String documentId,
  });
}
