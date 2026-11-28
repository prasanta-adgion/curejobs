import '../../../../core/result/result.dart';
import '../repositories/verification_repository.dart';

/// Deletes one attached document
/// (`DELETE verifications/{verificationId}/documents/{documentId}`),
/// e.g. a rejected one, so a new document can be uploaded.
class DeleteVerificationDocumentUseCase {
  final VerificationRepository _repository;

  const DeleteVerificationDocumentUseCase(this._repository);

  Future<Result<void>> call({
    required String verificationId,
    required String documentId,
  }) => _repository.deleteDocument(
    verificationId: verificationId,
    documentId: documentId,
  );
}
