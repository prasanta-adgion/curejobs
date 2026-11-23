import '../../../../core/result/result.dart';
import '../entities/verification_document_type.dart';
import '../repositories/verification_repository.dart';

/// Loads the document types the user can upload for verification.
class GetDocumentTypesUseCase {
  final VerificationRepository _repository;

  const GetDocumentTypesUseCase(this._repository);

  Future<Result<List<VerificationDocumentType>>> call() =>
      _repository.getDocumentTypes();
}
