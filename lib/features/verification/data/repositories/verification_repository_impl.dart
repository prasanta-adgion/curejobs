import '../../../../core/result/result.dart';
import '../../domain/entities/verification_document_type.dart';
import '../../domain/entities/verification_eligibility.dart';
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
  Future<Result<void>> submitDocument({
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
}
