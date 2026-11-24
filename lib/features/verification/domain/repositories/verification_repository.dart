import '../../../../core/result/result.dart';
import '../entities/verification_document_type.dart';
import '../entities/verification_eligibility.dart';

abstract interface class VerificationRepository {
  Future<Result<VerificationEligibility>> getEligibility();

  Future<Result<List<VerificationDocumentType>>> getDocumentTypes();

  /// Attaches one uploaded file to the request as [documentTypeId].
  Future<Result<void>> submitDocument({
    required String verificationId,
    required String documentTypeId,
    required String fileId,
  });
}
