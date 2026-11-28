import '../../../../core/result/result.dart';
import '../entities/verification_request_detail.dart';
import '../repositories/verification_repository.dart';

/// Loads a verification request with its documents, status and rejection
/// reason (`GET verifications/{id}`).
class GetVerificationRequestDetailUseCase {
  final VerificationRepository _repository;

  const GetVerificationRequestDetailUseCase(this._repository);

  Future<Result<VerificationRequestDetail>> call({
    required String verificationId,
  }) => _repository.getRequestDetail(verificationId: verificationId);
}
