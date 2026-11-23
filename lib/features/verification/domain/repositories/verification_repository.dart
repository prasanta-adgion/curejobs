import '../../../../core/result/result.dart';
import '../entities/verification_document_type.dart';
import '../entities/verification_eligibility.dart';

abstract interface class VerificationRepository {
  Future<Result<VerificationEligibility>> getEligibility();

  Future<Result<List<VerificationDocumentType>>> getDocumentTypes();
}
