import '../../../../core/result/result.dart';
import '../repositories/verification_repository.dart';

/// Attaches one already-uploaded file to a verification request
/// (`POST verifications/{id}/documents`).
class AddVerificationDocumentUseCase {
  final VerificationRepository _repository;

  const AddVerificationDocumentUseCase(this._repository);

  Future<Result<void>> call({
    required String verificationId,
    required String documentTypeId,
    required String fileId,
  }) => _repository.addDocument(
    verificationId: verificationId,
    documentTypeId: documentTypeId,
    fileId: fileId,
  );
}
